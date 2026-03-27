package com.ruoyi.system.service.biz;

import com.ruoyi.system.domain.biz.BizHealthRecord;

import java.util.List;

/**
 * 健康记录业务层
 */
public interface IBizHealthRecordService {
    BizHealthRecord selectHealthRecordById(Long recordId);

    List<BizHealthRecord> selectHealthRecordList(BizHealthRecord record);

    int insertHealthRecord(BizHealthRecord record);

    int deleteHealthRecordByIds(Long[] recordIds);

    void checkHealthAlert(BizHealthRecord record);
}
