package com.ruoyi.system.mapper.biz;

import com.ruoyi.system.domain.biz.BizHealthRecord;

import java.util.List;

/**
 * 健康记录数据层
 */
public interface BizHealthRecordMapper {
    BizHealthRecord selectHealthRecordById(Long recordId);

    List<BizHealthRecord> selectHealthRecordList(BizHealthRecord record);

    int insertHealthRecord(BizHealthRecord record);

    int deleteHealthRecordById(Long recordId);

    int deleteHealthRecordByIds(Long[] recordIds);
}
