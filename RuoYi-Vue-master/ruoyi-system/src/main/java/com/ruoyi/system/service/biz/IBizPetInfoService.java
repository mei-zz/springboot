package com.ruoyi.system.service.biz;

import com.ruoyi.system.domain.biz.BizPetInfo;

import java.util.List;

/**
 * 宠物档案业务层
 */
public interface IBizPetInfoService {
    BizPetInfo selectPetInfoById(Long petId);

    List<BizPetInfo> selectPetInfoList(BizPetInfo petInfo);

    int insertPetInfo(BizPetInfo petInfo);

    int updatePetInfo(BizPetInfo petInfo);

    int deletePetInfoByIds(Long[] petIds);

    List<BizPetInfo> getSocialMatchList(Long currentPetId);

    long countPetByOwnerUserId(Long ownerUserId);
}
