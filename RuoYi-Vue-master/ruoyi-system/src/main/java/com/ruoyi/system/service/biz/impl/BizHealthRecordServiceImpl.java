package com.ruoyi.system.service.biz.impl;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.biz.BizHealthAlert;
import com.ruoyi.system.domain.biz.BizHealthRecord;
import com.ruoyi.system.mapper.biz.BizHealthAlertMapper;
import com.ruoyi.system.mapper.biz.BizHealthRecordMapper;
import com.ruoyi.system.service.biz.IBizHealthRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

/**
 * 健康记录业务实现
 */
@Service
public class BizHealthRecordServiceImpl implements IBizHealthRecordService {
    @Autowired
    private BizHealthRecordMapper healthRecordMapper;
    @Autowired
    private BizHealthAlertMapper healthAlertMapper;

    @Override
    public BizHealthRecord selectHealthRecordById(Long recordId) {
        return healthRecordMapper.selectHealthRecordById(recordId);
    }

    @Override
    public List<BizHealthRecord> selectHealthRecordList(BizHealthRecord record) {
        return healthRecordMapper.selectHealthRecordList(record);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertHealthRecord(BizHealthRecord record) {
        if (record == null || record.getPetId() == null) {
            throw new ServiceException("健康记录参数不完整");
        }
        if (record.getRecordDate() == null) {
            record.setRecordDate(new Date());
        }
        boolean abnormal = "1".equals(record.getDefecationStatus()) || "2".equals(record.getMentalStatus());
        record.setIsAbnormal(abnormal ? "1" : "0");
        int rows = healthRecordMapper.insertHealthRecord(record);
        checkHealthAlert(record);
        return rows;
    }

    @Override
    public int deleteHealthRecordByIds(Long[] recordIds) {
        return healthRecordMapper.deleteHealthRecordByIds(recordIds);
    }

    /**
     * 固定阈值规则：排便异常或精神萎靡则生成预警
     */
    @Override
    public void checkHealthAlert(BizHealthRecord record) {
        if (record == null || record.getPetId() == null)
            return;
        boolean defAbnormal = "1".equals(record.getDefecationStatus());
        boolean mentalWeak = "2".equals(record.getMentalStatus());
        if (!defAbnormal && !mentalWeak)
            return;

        BizHealthAlert alert = new BizHealthAlert();
        alert.setPetId(record.getPetId());
        alert.setRecordId(record.getRecordId());
        alert.setAlertType("4");
        if (defAbnormal && mentalWeak) {
            alert.setAlertLevel("3");
            alert.setAlertContent("健康预警：检测到排便状态异常且精神状态萎靡，请尽快进行线下检查。");
        } else if (defAbnormal) {
            alert.setAlertLevel("2");
            alert.setAlertContent("健康预警：检测到排便状态异常，请持续观察并评估是否就医。");
        } else {
            alert.setAlertLevel("2");
            alert.setAlertContent("健康预警：检测到精神状态萎靡，请关注宠物活力与食欲变化。");
        }
        alert.setAlertTime(new Date());
        alert.setProcessStatus("0");
        alert.setProcessNote("");
        alert.setCreateBy(record.getCreateBy());
        alert.setUpdateBy(record.getUpdateBy());
        healthAlertMapper.insertHealthAlert(alert);
    }
}
