package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.mapper.biz.BizActivityMapper;
import com.ruoyi.system.mapper.biz.BizContentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 内容与活动审核控制器
 */
@RestController
@RequestMapping("/biz/audit")
public class BizAuditController extends BaseController {
    @Autowired
    private BizContentMapper contentMapper;

    @Autowired
    private BizActivityMapper activityMapper;

    @GetMapping("/content/list")
    public TableDataInfo contentList(@RequestParam(required = false) String reviewStatus) {
        startPage();
        List<Map<String, Object>> list = contentMapper.selectContentList(null, null, reviewStatus);
        return getDataTable(list);
    }

    @Log(title = "内容审核", businessType = BusinessType.UPDATE)
    @PutMapping("/content/{contentId}")
    public AjaxResult reviewContent(@PathVariable Long contentId, @RequestBody Map<String, Object> body) {
        String reviewStatus = String.valueOf(body.get("reviewStatus"));
        if (!"1".equals(reviewStatus) && !"2".equals(reviewStatus)) {
            throw new ServiceException("审核状态不合法");
        }
        String reviewNote = body.get("reviewNote") == null ? "" : String.valueOf(body.get("reviewNote"));
        return toAjax(contentMapper.updateContentReview(contentId, reviewStatus, reviewNote, getUsername()));
    }

    @GetMapping("/activity/list")
    public TableDataInfo activityList(@RequestParam(required = false) String reviewStatus) {
        startPage();
        List<Map<String, Object>> list = activityMapper.selectActivityList(reviewStatus, null);
        return getDataTable(list);
    }

    @Log(title = "活动审核", businessType = BusinessType.UPDATE)
    @PutMapping("/activity/{activityId}")
    public AjaxResult reviewActivity(@PathVariable Long activityId, @RequestBody Map<String, Object> body) {
        String reviewStatus = String.valueOf(body.get("reviewStatus"));
        if (!"1".equals(reviewStatus) && !"2".equals(reviewStatus)) {
            throw new ServiceException("审核状态不合法");
        }
        String reviewNote = body.get("reviewNote") == null ? "" : String.valueOf(body.get("reviewNote"));
        return toAjax(activityMapper.updateActivityReview(activityId, reviewStatus, reviewNote, getUsername()));
    }
}
