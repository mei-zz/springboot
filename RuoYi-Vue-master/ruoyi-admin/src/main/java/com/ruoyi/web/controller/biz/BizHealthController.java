package com.ruoyi.web.controller.biz;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.biz.BizHealthRecord;
import com.ruoyi.system.service.biz.IBizHealthRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 宠物健康控制器
 */
@RestController
@RequestMapping("/biz/health")
public class BizHealthController extends BaseController {
    @Autowired
    private IBizHealthRecordService healthRecordService;

    @GetMapping("/list")
    public TableDataInfo list(BizHealthRecord record) {
        startPage();
        List<BizHealthRecord> list = healthRecordService.selectHealthRecordList(record);
        return getDataTable(list);
    }

    @GetMapping("/{recordId}")
    public AjaxResult getInfo(@PathVariable Long recordId) {
        return success(healthRecordService.selectHealthRecordById(recordId));
    }

    @Log(title = "宠物健康记录", businessType = BusinessType.INSERT)
    @PostMapping("/record")
    public AjaxResult addRecord(@RequestBody BizHealthRecord record) {
        record.setCreateBy(getUsername());
        record.setUpdateBy(getUsername());
        return toAjax(healthRecordService.insertHealthRecord(record));
    }

    @Log(title = "宠物健康记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{recordIds}")
    public AjaxResult remove(@PathVariable Long[] recordIds) {
        return toAjax(healthRecordService.deleteHealthRecordByIds(recordIds));
    }
}
