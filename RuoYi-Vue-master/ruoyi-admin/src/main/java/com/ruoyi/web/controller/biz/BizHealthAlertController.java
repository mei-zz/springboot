package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.biz.BizHealthAlert;
import com.ruoyi.system.mapper.biz.BizHealthAlertMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 健康预警控制器
 */
@RestController
@RequestMapping("/biz/alert")
public class BizHealthAlertController extends BaseController {
    @Autowired
    private BizHealthAlertMapper healthAlertMapper;

    @GetMapping("/list")
    public TableDataInfo list(BizHealthAlert alert) {
        startPage();
        List<BizHealthAlert> list = healthAlertMapper.selectHealthAlertList(alert);
        return getDataTable(list);
    }

    @GetMapping("/{alertId}")
    public AjaxResult getInfo(@PathVariable Long alertId) {
        return success(healthAlertMapper.selectHealthAlertById(alertId));
    }

    /** 标记已处理 */
    @Log(title = "健康预警", businessType = BusinessType.UPDATE)
    @PutMapping("/process/{alertId}")
    public AjaxResult process(@PathVariable Long alertId, @RequestBody BizHealthAlert alert) {
        alert.setAlertId(alertId);
        alert.setProcessStatus("1");
        alert.setUpdateBy(getUsername());
        return toAjax(healthAlertMapper.updateHealthAlert(alert));
    }
}
