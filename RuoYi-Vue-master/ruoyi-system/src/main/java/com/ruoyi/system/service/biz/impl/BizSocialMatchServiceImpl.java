package com.ruoyi.system.service.biz.impl;

import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.biz.BizPetInfo;
import com.ruoyi.system.domain.biz.BizSocialMatch;
import com.ruoyi.system.mapper.biz.BizPetInfoMapper;
import com.ruoyi.system.mapper.biz.BizSocialMatchMapper;
import com.ruoyi.system.service.biz.IBizSocialMatchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 社交互动业务实现
 */
@Service
public class BizSocialMatchServiceImpl implements IBizSocialMatchService {
    @Autowired
    private BizSocialMatchMapper socialMatchMapper;

    @Autowired
    private BizPetInfoMapper petInfoMapper;

    @Override
    public int sendInvite(BizSocialMatch match) {
        if (match == null || match.getInitiatorPetId() == null || match.getReceiverPetId() == null) {
            throw new ServiceException("社交邀请参数不完整");
        }

        BizPetInfo initiatorPet = petInfoMapper.selectPetInfoById(match.getInitiatorPetId());
        BizPetInfo receiverPet = petInfoMapper.selectPetInfoById(match.getReceiverPetId());
        if (initiatorPet == null || receiverPet == null) {
            throw new ServiceException("社交邀请中的宠物信息不存在");
        }
        if (match.getInitiatorPetId().equals(match.getReceiverPetId())) {
            throw new ServiceException("不能向同一只宠物发送邀请");
        }
        if (match.getInitiatorUserId() == null) {
            match.setInitiatorUserId(initiatorPet.getOwnerUserId());
        } else if (!match.getInitiatorUserId().equals(initiatorPet.getOwnerUserId())) {
            throw new ServiceException("发起人用户与发起宠物归属不一致");
        }
        if (match.getReceiverUserId() == null) {
            match.setReceiverUserId(receiverPet.getOwnerUserId());
        } else if (!match.getReceiverUserId().equals(receiverPet.getOwnerUserId())) {
            throw new ServiceException("接收人用户与接收宠物归属不一致");
        }
        if (match.getInitiatorUserId().equals(match.getReceiverUserId())) {
            throw new ServiceException("不能向自己名下宠物发送邀请");
        }

        if (match.getMatchScore() == null) {
            match.setMatchScore(0);
        }
        if (match.getStatus() == null) {
            match.setStatus("1");
        }
        if (match.getInviteType() == null || match.getInviteType().trim().isEmpty()) {
            match.setInviteType("线下互动");
        }
        if (match.getEventLocation() == null) {
            match.setEventLocation("");
        }
        if (match.getInviteTime() == null) {
            match.setInviteTime(new Date());
        }
        return socialMatchMapper.insertSocialMatch(match);
    }

    @Override
    public List<BizSocialMatch> selectSocialHistoryByUserId(Long userId) {
        return socialMatchMapper.selectSocialMatchListByUserId(userId);
    }

    @Override
    public int respondInvite(Long matchId, String status, Long userId, String username) {
        BizSocialMatch current = socialMatchMapper.selectSocialMatchById(matchId);
        if (current == null) {
            throw new ServiceException("社交邀请不存在");
        }
        if (!current.getReceiverUserId().equals(userId)) {
            throw new ServiceException("只有接收方才能处理邀请");
        }
        if (!"1".equals(current.getStatus())) {
            throw new ServiceException("当前邀请状态不允许处理");
        }
        if (!"2".equals(status) && !"3".equals(status)) {
            throw new ServiceException("无效的响应状态");
        }
        BizSocialMatch update = new BizSocialMatch();
        update.setMatchId(matchId);
        update.setStatus(status);
        update.setResponseTime(new Date());
        update.setUpdateBy(username);
        return socialMatchMapper.updateSocialMatchResponse(update);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int addFriend(Long matchId, Long userId, String username) {
        BizSocialMatch current = socialMatchMapper.selectSocialMatchById(matchId);
        if (current == null) {
            throw new ServiceException("社交记录不存在");
        }
        if (!"2".equals(current.getStatus())) {
            throw new ServiceException("仅已接受的社交互动可添加好友");
        }
        if (!current.getInitiatorUserId().equals(userId) && !current.getReceiverUserId().equals(userId)) {
            throw new ServiceException("当前用户无权操作该社交记录");
        }
        if (socialMatchMapper.countFriendRelationByPets(current.getInitiatorPetId(), current.getReceiverPetId()) > 0) {
            throw new ServiceException("好友关系已存在");
        }

        int rows = 0;
        rows += socialMatchMapper.insertSocialFriend(current.getInitiatorUserId(), current.getReceiverUserId(),
                current.getInitiatorPetId(), current.getReceiverPetId(), current.getMatchId(), username, username);
        rows += socialMatchMapper.insertSocialFriend(current.getReceiverUserId(), current.getInitiatorUserId(),
                current.getReceiverPetId(), current.getInitiatorPetId(), current.getMatchId(), username, username);
        return rows;
    }

    @Override
    public List<Map<String, Object>> selectFriendListByUserId(Long userId) {
        return socialMatchMapper.selectFriendListByUserId(userId);
    }

    @Override
    public Map<String, Object> selectSocialStatsByUserId(Long userId) {
        Map<String, Object> stats = socialMatchMapper.selectSocialStatsByUserId(userId);
        if (stats == null) {
            stats = new LinkedHashMap<>();
            stats.put("successInteractionCount", 0);
            stats.put("pendingReceivedCount", 0);
            stats.put("pendingSentCount", 0);
            stats.put("friendCount", 0);
            stats.put("socialActivityScore", 0);
        }
        return stats;
    }

    @Override
    public List<Map<String, Object>> selectSocialRankList() {
        return socialMatchMapper.selectSocialRankList();
    }
}
