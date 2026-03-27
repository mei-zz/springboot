package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.system.domain.biz.BizPetInfo;
import com.ruoyi.system.mapper.biz.BizPetInfoMapper;
import com.ruoyi.system.mapper.biz.BizContentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 内容发布与推送控制器
 */
@RestController
@RequestMapping("/biz/content")
public class BizContentController extends BaseController {
    @Autowired
    private BizContentMapper contentMapper;

    @Autowired
    private BizPetInfoMapper petInfoMapper;

    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) String reviewStatus,
            @RequestParam(required = false) Integer mine) {
        startPage();
        Long creatorUserId = mine != null && mine == 1 ? getUserId() : null;
        List<Map<String, Object>> list = contentMapper.selectContentList("0", creatorUserId, reviewStatus);
        return getDataTable(list);
    }

    @GetMapping("/recommend")
    public TableDataInfo recommend() {
        startPage();
        List<Map<String, Object>> list = contentMapper.selectRecommendedContentByUserId(getUserId());
        return getDataTable(list);
    }

    @Log(title = "内容发布", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Map<String, Object> body) {
        Object petIdObj = body.get("petId");
        if (petIdObj == null) {
            throw new ServiceException("发布内容必须选择宠物");
        }
        Long petId = Long.valueOf(String.valueOf(petIdObj));
        BizPetInfo pet = petInfoMapper.selectPetInfoById(petId);
        if (pet == null || !getUserId().equals(pet.getOwnerUserId())) {
            throw new ServiceException("只能使用当前账号名下宠物发布内容");
        }
        Map<String, Object> content = new HashMap<>();
        content.put("creatorUserId", getUserId());
        content.put("petId", petId);
        content.put("contentType", body.get("contentType"));
        content.put("title", body.get("title"));
        content.put("summary", body.get("summary"));
        content.put("contentText", body.get("contentText"));
        content.put("tags", body.get("tags"));
        content.put("mediaUrl", body.get("mediaUrl"));
        content.put("reviewStatus", "0");
        content.put("createBy", getUsername());
        content.put("updateBy", getUsername());
        return toAjax(contentMapper.insertContent(content));
    }
}
