package com.ruoyi.system.mapper.biz;

import com.ruoyi.system.domain.biz.BizHealthAlert;

import java.util.List;

/**
 * 健康预警数据层
 */
public interface BizHealthAlertMapper {
    BizHealthAlert selectHealthAlertById(Long alertId);

    List<BizHealthAlert> selectHealthAlertList(BizHealthAlert alert);

    int insertHealthAlert(BizHealthAlert alert);

    int updateHealthAlert(BizHealthAlert alert);

    int deleteHealthAlertById(Long alertId);

    int deleteHealthAlertByIds(Long[] alertIds);
}
