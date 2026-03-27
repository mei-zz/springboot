package com.ruoyi.system.service.biz;

import com.ruoyi.system.domain.biz.BizSocialMatch;

import java.util.List;
import java.util.Map;

/**
 * 社交互动业务层
 */
public interface IBizSocialMatchService {
    int sendInvite(BizSocialMatch match);

    List<BizSocialMatch> selectSocialHistoryByUserId(Long userId);

    int respondInvite(Long matchId, String status, Long userId, String username);

    int addFriend(Long matchId, Long userId, String username);

    List<Map<String, Object>> selectFriendListByUserId(Long userId);

    Map<String, Object> selectSocialStatsByUserId(Long userId);

    List<Map<String, Object>> selectSocialRankList();
}
