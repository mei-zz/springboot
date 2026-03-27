package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.biz.BizPetInfo;
import com.ruoyi.system.mapper.biz.BizActivityMapper;
import com.ruoyi.system.mapper.biz.BizPetInfoMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 社区活动控制器
 */
@RestController
@RequestMapping("/biz/activity")
public class BizActivityController extends BaseController {
    @Autowired
    private BizActivityMapper activityMapper;

    @Autowired
    private BizPetInfoMapper petInfoMapper;

    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) Integer mine,
            @RequestParam(required = false) String reviewStatus) {
        startPage();
        Long creatorUserId = mine != null && mine == 1 ? getUserId() : null;
        List<Map<String, Object>> list = activityMapper.selectActivityList(reviewStatus, creatorUserId);
        return getDataTable(list);
    }

    @Log(title = "活动发布", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Map<String, Object> body) {
        Map<String, Object> activity = new HashMap<>();
        activity.put("creatorUserId", getUserId());
        activity.put("title", body.get("title"));
        activity.put("activityType", body.get("activityType"));
        activity.put("location", body.get("location"));
        activity.put("startTime", body.get("startTime"));
        activity.put("endTime", body.get("endTime"));
        activity.put("petSizeLimit", body.get("petSizeLimit"));
        activity.put("maxParticipants", body.get("maxParticipants"));
        activity.put("description", body.get("description"));
        activity.put("reviewStatus", "0");
        activity.put("status", "0");
        activity.put("createBy", getUsername());
        activity.put("updateBy", getUsername());
        return toAjax(activityMapper.insertActivity(activity));
    }

    @Log(title = "活动报名", businessType = BusinessType.INSERT)
    @PostMapping("/signup/{activityId}")
    public AjaxResult signup(@PathVariable Long activityId, @RequestBody Map<String, Object> body) {
        Object petIdObj = body.get("petId");
        if (petIdObj == null) {
            throw new ServiceException("报名需要选择宠物");
        }
        Long petId = Long.valueOf(String.valueOf(petIdObj));
        BizPetInfo pet = petInfoMapper.selectPetInfoById(petId);
        if (pet == null || !getUserId().equals(pet.getOwnerUserId())) {
            throw new ServiceException("只能使用当前账号名下宠物报名活动");
        }
        Map<String, Object> activity = activityMapper.selectActivityById(activityId);
        if (activity == null) {
            throw new ServiceException("活动不存在");
        }
        if (!"1".equals(String.valueOf(activity.get("reviewStatus")))) {
            throw new ServiceException("活动未审核通过，暂不可报名");
        }
        int exists = activityMapper.countSignup(activityId, getUserId(), petId);
        if (exists > 0) {
            throw new ServiceException("请勿重复报名");
        }
        int rows = activityMapper.insertSignup(activityId, getUserId(), petId, getUsername(), getUsername());
        if (rows > 0) {
            activityMapper.increaseParticipants(activityId);
        }
        return toAjax(rows);
    }

    @GetMapping("/signup/my")
    public TableDataInfo mySignup() {
        startPage();
        List<Map<String, Object>> list = activityMapper.selectMySignupList(getUserId());
        return getDataTable(list);
    }
}
