package com.ruoyi.system.mapper.biz;

import com.ruoyi.system.domain.biz.BizSocialMatch;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 社交互动数据层
 */
public interface BizSocialMatchMapper {
    int insertSocialMatch(BizSocialMatch match);

    BizSocialMatch selectSocialMatchById(@Param("matchId") Long matchId);

    List<BizSocialMatch> selectSocialMatchListByUserId(@Param("userId") Long userId);

    int updateSocialMatchResponse(BizSocialMatch match);

    int countFriendRelationByPets(@Param("petId") Long petId, @Param("friendPetId") Long friendPetId);

    int insertSocialFriend(@Param("userId") Long userId,
            @Param("friendUserId") Long friendUserId,
            @Param("petId") Long petId,
            @Param("friendPetId") Long friendPetId,
            @Param("sourceMatchId") Long sourceMatchId,
            @Param("createBy") String createBy,
            @Param("updateBy") String updateBy);

    List<Map<String, Object>> selectFriendListByUserId(@Param("userId") Long userId);

    Map<String, Object> selectSocialStatsByUserId(@Param("userId") Long userId);

    List<Map<String, Object>> selectSocialRankList();
}
