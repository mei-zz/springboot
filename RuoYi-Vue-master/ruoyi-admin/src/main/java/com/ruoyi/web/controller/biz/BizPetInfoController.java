package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.biz.BizPetInfo;
import com.ruoyi.system.service.biz.IBizPetInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 宠物档案控制器
 */
@RestController
@RequestMapping("/biz/pet")
public class BizPetInfoController extends BaseController {
    @Autowired
    private IBizPetInfoService petInfoService;

    @PreAuthorize("@ss.hasPermi('biz:pet:list')")
    @GetMapping("/list")
    public TableDataInfo list(BizPetInfo petInfo) {
        if (!SecurityUtils.isAdmin(getUserId())) {
            petInfo.setOwnerUserId(getUserId());
        }
        startPage();
        List<BizPetInfo> list = petInfoService.selectPetInfoList(petInfo);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('biz:pet:list')")
    @GetMapping("/{petId}")
    public AjaxResult getInfo(@PathVariable Long petId) {
        BizPetInfo petInfo = petInfoService.selectPetInfoById(petId);
        validateOwnerPermission(petInfo);
        return success(petInfo);
    }

    @Log(title = "宠物档案", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('biz:pet:list')")
    @PostMapping
    public AjaxResult add(@RequestBody BizPetInfo petInfo) {
        petInfo.setOwnerUserId(getUserId());
        petInfo.setCreateBy(getUsername());
        petInfo.setUpdateBy(getUsername());
        return toAjax(petInfoService.insertPetInfo(petInfo));
    }

    @Log(title = "宠物档案", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('biz:pet:list')")
    @PutMapping
    public AjaxResult edit(@RequestBody BizPetInfo petInfo) {
        BizPetInfo dbPet = petInfoService.selectPetInfoById(petInfo.getPetId());
        validateOwnerPermission(dbPet);
        petInfo.setOwnerUserId(dbPet.getOwnerUserId());
        petInfo.setUpdateBy(getUsername());
        return toAjax(petInfoService.updatePetInfo(petInfo));
    }

    @Log(title = "宠物档案", businessType = BusinessType.DELETE)
    @PreAuthorize("@ss.hasPermi('biz:pet:list')")
    @DeleteMapping("/{petIds}")
    public AjaxResult remove(@PathVariable Long[] petIds) {
        for (Long petId : petIds) {
            BizPetInfo dbPet = petInfoService.selectPetInfoById(petId);
            validateOwnerPermission(dbPet);
        }
        return toAjax(petInfoService.deletePetInfoByIds(petIds));
    }

    private void validateOwnerPermission(BizPetInfo petInfo) {
        if (petInfo == null) {
            throw new ServiceException("宠物档案不存在");
        }
        Long userId = getUserId();
        if (!SecurityUtils.isAdmin(userId) && !userId.equals(petInfo.getOwnerUserId())) {
            throw new ServiceException("无权操作他人的宠物档案");
        }
    }
}
