package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.biz.BizPetInfo;
import com.ruoyi.system.domain.biz.BizSocialMatch;
import com.ruoyi.system.service.biz.IBizPetInfoService;
import com.ruoyi.system.service.biz.IBizSocialMatchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 宠物社交控制器
 */
@RestController
@RequestMapping("/biz/social")
public class BizSocialController extends BaseController {
    @Autowired
    private IBizPetInfoService petInfoService;

    @Autowired
    private IBizSocialMatchService socialMatchService;

    /**
     * 获取社交匹配列表
     */
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @GetMapping("/match/{currentPetId}")
    public AjaxResult getMatchList(@PathVariable Long currentPetId) {
        validatePetOwner(currentPetId);
        List<BizPetInfo> list = petInfoService.getSocialMatchList(currentPetId);
        return AjaxResult.success(list);
    }

    /**
     * 发送社交邀请
     */
    @Log(title = "宠物社交邀请", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @PostMapping("/invite")
    public AjaxResult sendInvite(@RequestBody BizSocialMatch match) {
        validatePetOwner(match.getInitiatorPetId());
        BizPetInfo receiverPet = petInfoService.selectPetInfoById(match.getReceiverPetId());
        if (receiverPet == null) {
            throw new ServiceException("被邀请宠物不存在");
        }
        match.setInitiatorUserId(getUserId());
        match.setReceiverUserId(receiverPet.getOwnerUserId());
        match.setCreateBy(getUsername());
        match.setUpdateBy(getUsername());
        return toAjax(socialMatchService.sendInvite(match));
    }

    /**
     * 当前账号的社交历史/收件箱
     */
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @GetMapping("/history")
    public TableDataInfo history() {
        startPage();
        List<BizSocialMatch> list = socialMatchService.selectSocialHistoryByUserId(getUserId());
        return getDataTable(list);
    }

    /**
     * 接受/拒绝邀请
     */
    @Log(title = "社交邀请处理", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @PutMapping("/respond/{matchId}")
    public AjaxResult respond(@PathVariable Long matchId, @RequestBody BizSocialMatch match) {
        return toAjax(socialMatchService.respondInvite(matchId, match.getStatus(), getUserId(), getUsername()));
    }

    /**
     * 基于成功社交记录添加好友
     */
    @Log(title = "宠物好友关系", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @PostMapping("/friend/{matchId}")
    public AjaxResult addFriend(@PathVariable Long matchId) {
        return toAjax(socialMatchService.addFriend(matchId, getUserId(), getUsername()));
    }

    /**
     * 当前账号好友列表
     */
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @GetMapping("/friends")
    public TableDataInfo friends() {
        startPage();
        List<Map<String, Object>> list = socialMatchService.selectFriendListByUserId(getUserId());
        return getDataTable(list);
    }

    /**
     * 社交统计概览
     */
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @GetMapping("/stats")
    public AjaxResult stats() {
        return success(socialMatchService.selectSocialStatsByUserId(getUserId()));
    }

    /**
     * 社区社交活跃度排行
     */
    @PreAuthorize("@ss.hasPermi('biz:social:list')")
    @GetMapping("/rank")
    public TableDataInfo rank() {
        startPage();
        List<Map<String, Object>> list = socialMatchService.selectSocialRankList();
        return getDataTable(list);
    }

    private void validatePetOwner(Long petId) {
        if (petId == null) {
            throw new ServiceException("宠物ID不能为空");
        }
        BizPetInfo petInfo = petInfoService.selectPetInfoById(petId);
        if (petInfo == null) {
            throw new ServiceException("宠物不存在");
        }
        Long userId = getUserId();
        if (!SecurityUtils.isAdmin(userId) && !userId.equals(petInfo.getOwnerUserId())) {
            throw new ServiceException("只能使用自己名下宠物进行社交互动");
        }
    }
}
