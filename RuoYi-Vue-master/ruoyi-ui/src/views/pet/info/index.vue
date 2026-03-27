<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
      <el-form-item label="宠物昵称" prop="petName">
        <el-input v-model="queryParams.petName" placeholder="请输入宠物昵称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="品种" prop="breed">
        <el-input v-model="queryParams.breed" placeholder="请输入品种" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="社交标签" prop="socialTags">
        <el-input v-model="queryParams.socialTags" placeholder="如：金毛,活泼" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 操作按钮 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 表格 -->
    <el-table v-loading="loading" :data="petList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="宠物ID" prop="petId" width="80" align="center" />
      <el-table-column label="宠物昵称" prop="petName" align="center" />
      <el-table-column label="性别" prop="petGender" width="70" align="center">
        <template slot-scope="scope">
          <span>{{ genderLabel(scope.row.petGender) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="品种" prop="breed" align="center" />
      <el-table-column label="体重(kg)" prop="weightKg" align="center" width="90" />
      <el-table-column label="社交标签" prop="socialTags" align="center" show-overflow-tooltip>
        <template slot-scope="scope">
          <el-tag
            v-for="tag in splitTags(scope.row.socialTags)"
            :key="tag"
            size="mini"
            type="success"
            style="margin:2px"
          >{{ tag }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status" width="80" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'" size="mini">
            {{ scope.row.status === '0' ? '正常' : '停用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">{{ parseTime(scope.row.createTime, '{y}-{m}-{d}') }}</template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="160">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="600px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="宠物昵称" prop="petName">
              <el-input v-model="form.petName" placeholder="请输入宠物昵称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="petGender">
              <el-select v-model="form.petGender" style="width:100%">
                <el-option label="公" value="0" />
                <el-option label="母" value="1" />
                <el-option label="未知" value="2" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="品种" prop="breed">
              <el-input v-model="form.breed" placeholder="如：金毛" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="体重(kg)" prop="weightKg">
              <el-input-number v-model="form.weightKg" :precision="2" :min="0" :max="200" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="出生日期" prop="birthday">
              <el-date-picker v-model="form.birthday" type="date" value-format="yyyy-MM-dd" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-radio-group v-model="form.status">
                <el-radio label="0">正常</el-radio>
                <el-radio label="1">停用</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="社交标签" prop="socialTags">
              <el-input v-model="form.socialTags" placeholder="多个标签用英文逗号分隔，如：金毛,活泼,亲人" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="健康备注">
              <el-input v-model="form.healthNote" type="textarea" :rows="2" placeholder="健康情况备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listPetInfo, getPetInfo, addPetInfo, updatePetInfo, delPetInfo } from '@/api/pet/petInfo'

export default {
  name: 'PetInfo',
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      petList: [],
      title: '',
      open: false,
      queryParams: { pageNum: 1, pageSize: 10, petName: undefined, breed: undefined, socialTags: undefined },
      form: {},
      rules: {
        petName: [{ required: true, message: '宠物昵称不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listPetInfo(this.queryParams).then(res => {
        this.petList = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    genderLabel(val) {
      return val === '0' ? '公' : val === '1' ? '母' : '未知'
    },
    splitTags(str) {
      if (!str) return []
      return str.split(',').map(s => s.trim()).filter(Boolean)
    },
    cancel() { this.open = false; this.reset() },
    reset() {
      this.form = { petId: undefined, petName: undefined, petGender: '2', breed: undefined,
        birthday: undefined, weightKg: undefined, socialTags: undefined, healthNote: undefined, status: '0' }
      this.resetForm('form')
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    handleSelectionChange(sel) {
      this.ids = sel.map(i => i.petId)
      this.single = sel.length !== 1
      this.multiple = !sel.length
    },
    handleAdd() { this.reset(); this.open = true; this.title = '新增宠物档案' },
    handleUpdate(row) {
      this.reset()
      const id = row.petId || this.ids[0]
      getPetInfo(id).then(res => { this.form = res.data; this.open = true; this.title = '修改宠物档案' })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const action = this.form.petId ? updatePetInfo : addPetInfo
        action(this.form).then(() => {
          this.$modal.msgSuccess(this.form.petId ? '修改成功' : '新增成功')
          this.open = false
          this.getList()
        })
      })
    },
    handleDelete(row) {
      const ids = row.petId || this.ids
      this.$modal.confirm('确认删除选中宠物档案？').then(() => {
        return delPetInfo(ids)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    }
  }
}
</script>
