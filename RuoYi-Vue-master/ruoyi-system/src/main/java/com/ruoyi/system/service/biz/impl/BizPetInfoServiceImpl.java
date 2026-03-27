package com.ruoyi.system.service.biz.impl;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.biz.BizPetInfo;
import com.ruoyi.system.mapper.biz.BizPetInfoMapper;
import com.ruoyi.system.service.biz.IBizPetInfoService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 宠物档案业务实现
 */
@Service
public class BizPetInfoServiceImpl implements IBizPetInfoService {
    @Autowired
    private BizPetInfoMapper petInfoMapper;

    @Override
    public BizPetInfo selectPetInfoById(Long petId) {
        return petInfoMapper.selectPetInfoById(petId);
    }

    @Override
    public List<BizPetInfo> selectPetInfoList(BizPetInfo petInfo) {
        return petInfoMapper.selectPetInfoList(petInfo);
    }

    @Override
    public int insertPetInfo(BizPetInfo petInfo) {
        return petInfoMapper.insertPetInfo(petInfo);
    }

    @Override
    public int updatePetInfo(BizPetInfo petInfo) {
        return petInfoMapper.updatePetInfo(petInfo);
    }

    @Override
    public int deletePetInfoByIds(Long[] petIds) {
        return petInfoMapper.deletePetInfoByIds(petIds);
    }

    @Override
    public long countPetByOwnerUserId(Long ownerUserId) {
        if (ownerUserId == null) {
            return 0;
        }
        return petInfoMapper.countPetByOwnerUserId(ownerUserId);
    }

    /**
     * 社交标签匹配：根据当前宠物标签在库内模糊筛选候选对象，并按标签交集数量计算匹配度。
     */
    @Override
    public List<BizPetInfo> getSocialMatchList(Long currentPetId) {
        if (currentPetId == null) {
            throw new ServiceException("当前宠物ID不能为空");
        }
        BizPetInfo currentPet = petInfoMapper.selectPetInfoById(currentPetId);
        if (currentPet == null) {
            throw new ServiceException("当前宠物不存在");
        }
        List<String> currentTagList = splitTags(currentPet.getSocialTags());
        if (currentTagList.isEmpty()) {
            return Collections.emptyList();
        }
        List<BizPetInfo> candidates = petInfoMapper.selectPetListByTagKeywords(currentPetId, currentTagList);
        if (candidates == null || candidates.isEmpty()) {
            return Collections.emptyList();
        }
        Set<String> currentTagSet = new LinkedHashSet<>(currentTagList);
        List<BizPetInfo> result = new ArrayList<>();
        for (BizPetInfo candidate : candidates) {
            Set<String> overlap = splitTags(candidate.getSocialTags()).stream()
                    .filter(currentTagSet::contains)
                    .collect(Collectors.toCollection(LinkedHashSet::new));
            if (!overlap.isEmpty()) {
                candidate.setMatchScore(Math.min((int) Math.round(overlap.size() * 100.0 / currentTagSet.size()), 100));
                candidate.setMatchedTags(String.join(",", overlap));
                result.add(candidate);
            }
        }
        result.sort(Comparator.comparing(BizPetInfo::getMatchScore, Comparator.nullsLast(Comparator.reverseOrder())));
        return result;
    }

    private List<String> splitTags(String tagText) {
        if (StringUtils.isBlank(tagText))
            return Collections.emptyList();
        return Arrays.stream(tagText.split(","))
                .map(String::trim)
                .filter(StringUtils::isNotBlank)
                .distinct()
                .collect(Collectors.toList());
    }
}
