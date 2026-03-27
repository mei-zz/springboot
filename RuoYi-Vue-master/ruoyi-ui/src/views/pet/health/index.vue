<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
      <el-form-item label="宠物ID" prop="petId">
        <el-input v-model="queryParams.petId" placeholder="请输入宠物ID" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="是否异常" prop="isAbnormal">
        <el-select v-model="queryParams.isAbnormal" placeholder="全部" clearable>
          <el-option label="正常" value="0" />
          <el-option label="异常" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">新增记录</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="recordList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="记录ID" prop="recordId" width="80" align="center" />
      <el-table-column label="宠物ID" prop="petId" width="80" align="center" />
      <el-table-column label="记录日期" prop="recordDate" align="center" width="120">
        <template slot-scope="scope">{{ parseTime(scope.row.recordDate, '{y}-{m}-{d}') }}</template>
      </el-table-column>
      <el-table-column label="体重(kg)" prop="weightKg" align="center" width="90" />
      <el-table-column label="饮食量(g)" prop="foodIntakeG" align="center" width="90" />
      <el-table-column label="排便状态" prop="defecationStatus" align="center" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.defecationStatus === '0' ? 'success' : 'danger'" size="mini">
            {{ scope.row.defecationStatus === '0' ? '正常' : '异常' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="精神状态" prop="mentalStatus" align="center" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.mentalStatus === '0' ? 'success' : scope.row.mentalStatus === '1' ? 'warning' : 'danger'" size="mini">
            {{ mentalLabel(scope.row.mentalStatus) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="是否异常" prop="isAbnormal" align="center" width="90">
        <template slot-scope="scope">
          <el-tag :type="scope.row.isAbnormal === '0' ? 'success' : 'danger'" size="mini">
            {{ scope.row.isAbnormal === '0' ? '正常' : '异常' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="症状描述" prop="symptomDesc" align="center" show-overflow-tooltip />
      <el-table-column label="记录时间" prop="createTime" align="center" width="160">
        <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="80">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 新增健康记录对话框 -->
    <el-dialog title="新增健康记录" :visible.sync="open" width="560px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="宠物ID" prop="petId">
              <el-input-number v-model="form.petId" :min="1" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="记录日期" prop="recordDate">
              <el-date-picker v-model="form.recordDate" type="date" value-format="yyyy-MM-dd" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="体重(kg)">
              <el-input-number v-model="form.weightKg" :precision="2" :min="0" :max="200" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="饮食量(g)">
              <el-input-number v-model="form.foodIntakeG" :precision="1" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排便状态" prop="defecationStatus">
              <el-radio-group v-model="form.defecationStatus">
                <el-radio label="0">正常</el-radio>
                <el-radio label="1">异常</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="精神状态" prop="mentalStatus">
              <el-select v-model="form.mentalStatus" style="width:100%">
                <el-option label="良好" value="0" />
                <el-option label="一般" value="1" />
                <el-option label="萎靡" value="2" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="症状描述">
              <el-input v-model="form.symptomDesc" type="textarea" :rows="2" placeholder="请描述症状" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <el-alert
        v-if="form.defecationStatus === '1' || form.mentalStatus === '2'"
        title="检测到异常状态，提交后将自动生成健康预警！"
        type="warning"
        :closable="false"
        show-icon
        style="margin-bottom:10px"
      />
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listHealthRecord, addHealthRecord, delHealthRecord } from '@/api/pet/health'

export default {
  name: 'HealthRecord',
  data() {
    return {
      loading: true,
      ids: [],
      multiple: true,
      showSearch: true,
      total: 0,
      recordList: [],
      open: false,
      queryParams: { pageNum: 1, pageSize: 10, petId: undefined, isAbnormal: undefined },
      form: {},
      rules: {
        petId: [{ required: true, message: '宠物ID不能为空', trigger: 'blur' }],
        defecationStatus: [{ required: true, message: '请选择排便状态', trigger: 'change' }],
        mentalStatus: [{ required: true, message: '请选择精神状态', trigger: 'change' }]
      }
    }
  },
  created() { this.getList() },
  methods: {
    getList() {
      this.loading = true
      listHealthRecord(this.queryParams).then(res => {
        this.recordList = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    mentalLabel(val) { return val === '0' ? '良好' : val === '1' ? '一般' : '萎靡' },
    cancel() { this.open = false; this.reset() },
    reset() {
      this.form = { petId: undefined, recordDate: undefined, weightKg: undefined,
        foodIntakeG: undefined, defecationStatus: '0', mentalStatus: '0', symptomDesc: undefined }
      this.resetForm('form')
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    handleSelectionChange(sel) { this.ids = sel.map(i => i.recordId); this.multiple = !sel.length },
    handleAdd() { this.reset(); this.open = true },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        addHealthRecord(this.form).then(() => {
          const hasAlert = this.form.defecationStatus === '1' || this.form.mentalStatus === '2'
          this.$modal.msgSuccess('新增成功' + (hasAlert ? '，已自动生成健康预警' : ''))
          this.open = false
          this.getList()
        })
      })
    },
    handleDelete(row) {
      const ids = row.recordId || this.ids
      this.$modal.confirm('确认删除选中记录？').then(() => delHealthRecord(ids))
        .then(() => { this.getList(); this.$modal.msgSuccess('删除成功') }).catch(() => {})
    }
  }
}
</script>
