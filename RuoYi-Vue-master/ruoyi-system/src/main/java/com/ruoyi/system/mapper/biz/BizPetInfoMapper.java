package com.ruoyi.system.mapper.biz;

import com.ruoyi.system.domain.biz.BizPetInfo;

import java.util.List;

/**
 * 宠物档案数据层
 */
public interface BizPetInfoMapper {
    BizPetInfo selectPetInfoById(Long petId);

    List<BizPetInfo> selectPetInfoList(BizPetInfo petInfo);

    int insertPetInfo(BizPetInfo petInfo);

    int updatePetInfo(BizPetInfo petInfo);

    int deletePetInfoById(Long petId);

    int deletePetInfoByIds(Long[] petIds);

    List<BizPetInfo> selectPetListByTagKeywords(Long currentPetId, List<String> tagKeywords);

    long countPetByOwnerUserId(Long ownerUserId);
}
