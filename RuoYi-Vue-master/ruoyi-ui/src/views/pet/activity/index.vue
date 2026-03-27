<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" @tab-click="handleTabChange">
      <el-tab-pane label="活动大厅" name="hall">
        <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
          <el-form-item label="审核状态" prop="reviewStatus">
            <el-select v-model="queryParams.reviewStatus" clearable placeholder="全部">
              <el-option label="待审核" value="0" />
              <el-option label="已通过" value="1" />
              <el-option label="已拒绝" value="2" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
            <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">发布活动</el-button>
          </el-col>
          <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
        </el-row>

        <el-table v-loading="loading" :data="activityList">
          <el-table-column label="活动标题" prop="title" min-width="180" show-overflow-tooltip />
          <el-table-column label="类型" prop="activityType" width="100" align="center" />
          <el-table-column label="发起人" prop="creatorName" width="120" align="center" />
          <el-table-column label="地点" prop="location" min-width="150" show-overflow-tooltip />
          <el-table-column label="活动时间" min-width="220" align="center">
            <template slot-scope="scope">
              {{ parseTime(scope.row.startTime) }} ~ {{ parseTime(scope.row.endTime) }}
            </template>
          </el-table-column>
          <el-table-column label="人数" width="110" align="center">
            <template slot-scope="scope">
              {{ scope.row.currentParticipants || 0 }} / {{ scope.row.maxParticipants || '不限' }}
            </template>
          </el-table-column>
          <el-table-column label="审核" width="90" align="center">
            <template slot-scope="scope">
              <el-tag :type="reviewTagType(scope.row.reviewStatus)" size="mini">{{ reviewLabel(scope.row.reviewStatus) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="90" align="center">
            <template slot-scope="scope">
              <el-tag :type="statusTagType(scope.row.status)" size="mini">{{ statusLabel(scope.row.status) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" align="center">
            <template slot-scope="scope">
              <el-button size="mini" type="text" icon="el-icon-check" :disabled="scope.row.reviewStatus !== '1'" @click="openSignup(scope.row)">报名</el-button>
            </template>
          </el-table-column>
        </el-table>

        <pagination
          v-show="total > 0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </el-tab-pane>

      <el-tab-pane label="我的报名" name="signup">
        <el-table v-loading="signupLoading" :data="signupList">
          <el-table-column label="活动" prop="activityTitle" min-width="180" show-overflow-tooltip />
          <el-table-column label="类型" prop="activityType" width="120" align="center" />
          <el-table-column label="我的宠物" prop="petName" width="120" align="center" />
          <el-table-column label="地点" prop="location" min-width="150" show-overflow-tooltip />
          <el-table-column label="活动时间" min-width="220" align="center">
            <template slot-scope="scope">
              {{ parseTime(scope.row.startTime) }} ~ {{ parseTime(scope.row.endTime) }}
            </template>
          </el-table-column>
          <el-table-column label="报名时间" width="160" align="center">
            <template slot-scope="scope">{{ parseTime(scope.row.signupTime) }}</template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog title="发布社区活动" :visible.sync="open" width="680px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="活动标题" prop="title">
              <el-input v-model="form.title" maxlength="100" show-word-limit />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="活动类型" prop="activityType">
              <el-select v-model="form.activityType" style="width:100%">
                <el-option label="线下遛宠" value="线下遛宠" />
                <el-option label="宠友聚会" value="宠友聚会" />
                <el-option label="经验分享" value="经验分享" />
                <el-option label="领养公益" value="领养公益" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="开始时间" prop="startTime">
              <el-date-picker v-model="form.startTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结束时间" prop="endTime">
              <el-date-picker v-model="form.endTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="活动地点" prop="location">
              <el-input v-model="form.location" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="人数上限">
              <el-input-number v-model="form.maxParticipants" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="体型限制">
              <el-select v-model="form.petSizeLimit" style="width:100%">
                <el-option label="不限" value="不限" />
                <el-option label="小型" value="小型" />
                <el-option label="中型" value="中型" />
                <el-option label="大型" value="大型" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="活动说明" prop="description">
              <el-input v-model="form.description" type="textarea" :rows="4" maxlength="1000" show-word-limit />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">发 布</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="活动报名" :visible.sync="signupOpen" width="500px" append-to-body>
      <el-form ref="signupForm" :model="signupForm" :rules="signupRules" label-width="90px">
        <el-form-item label="活动标题">
          <el-input :value="selectedActivity ? selectedActivity.title : ''" disabled />
        </el-form-item>
        <el-form-item label="报名宠物" prop="petId">
          <el-select v-model="signupForm.petId" placeholder="请选择宠物" style="width:100%" filterable>
            <el-option v-for="pet in myPets" :key="pet.petId" :label="pet.petName + '（' + (pet.breed || '未知品种') + '）'" :value="pet.petId" />
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitSignup">提 交</el-button>
        <el-button @click="signupOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addActivity, listActivity, listMySignups, signupActivity } from '@/api/pet/activity'
import { listPetInfo } from '@/api/pet/petInfo'
import { mapGetters } from 'vuex'

export default {
  name: 'PetActivity',
  data() {
    return {
      activeTab: 'hall',
      showSearch: true,
      loading: false,
      signupLoading: false,
      total: 0,
      activityList: [],
      signupList: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        reviewStatus: undefined
      },
      open: false,
      form: {},
      rules: {
        title: [{ required: true, message: '活动标题不能为空', trigger: 'blur' }],
        activityType: [{ required: true, message: '活动类型不能为空', trigger: 'change' }],
        location: [{ required: true, message: '活动地点不能为空', trigger: 'blur' }],
        startTime: [{ required: true, message: '开始时间不能为空', trigger: 'change' }],
        endTime: [{ required: true, message: '结束时间不能为空', trigger: 'change' }],
        description: [{ required: true, message: '活动说明不能为空', trigger: 'blur' }]
      },
      signupOpen: false,
      selectedActivity: null,
      signupForm: { petId: undefined },
      signupRules: {
        petId: [{ required: true, message: '请选择报名宠物', trigger: 'change' }]
      },
      myPets: []
    }
  },
  computed: {
    ...mapGetters(['id']),
    userId() {
      return Number(this.id)
    }
  },
  created() {
    this.getList()
    this.getMySignups()
    this.loadMyPets()
  },
  methods: {
    getList() {
      this.loading = true
      listActivity(this.queryParams).then(res => {
        this.activityList = res.rows || []
        this.total = res.total || 0
        this.loading = false
      }).catch(() => { this.loading = false })
    },
    getMySignups() {
      this.signupLoading = true
      listMySignups({ pageNum: 1, pageSize: 50 }).then(res => {
        this.signupList = res.rows || []
        this.signupLoading = false
      }).catch(() => { this.signupLoading = false })
    },
    loadMyPets() {
      listPetInfo({ pageNum: 1, pageSize: 100, ownerUserId: this.userId, status: '0' }).then(res => {
        this.myPets = res.rows || []
      })
    },
    handleTabChange() {
      if (this.activeTab === 'hall') {
        this.getList()
      } else {
        this.getMySignups()
      }
    },
    reviewLabel(status) {
      return ({ '0': '待审核', '1': '已通过', '2': '已拒绝' })[status] || '未知'
    },
    reviewTagType(status) {
      return ({ '0': 'warning', '1': 'success', '2': 'danger' })[status] || 'info'
    },
    statusLabel(status) {
      return ({ '0': '草稿', '1': '进行中', '2': '结束', '3': '已拒绝' })[status] || '未知'
    },
    statusTagType(status) {
      return ({ '0': 'info', '1': 'success', '2': 'warning', '3': 'danger' })[status] || 'info'
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    reset() {
      this.form = {
        title: '',
        activityType: '线下遛宠',
        location: '',
        startTime: '',
        endTime: '',
        petSizeLimit: '不限',
        maxParticipants: 0,
        description: ''
      }
      this.resetForm('form')
    },
    handleAdd() {
      this.reset()
      this.open = true
    },
    cancel() {
      this.open = false
      this.reset()
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (new Date(this.form.endTime).getTime() <= new Date(this.form.startTime).getTime()) {
          this.$modal.msgError('结束时间必须晚于开始时间')
          return
        }
        addActivity(this.form).then(() => {
          this.$modal.msgSuccess('发布成功，待管理员审核')
          this.open = false
          this.getList()
        })
      })
    },
    openSignup(row) {
      this.selectedActivity = row
      this.signupForm = { petId: undefined }
      this.resetForm('signupForm')
      this.signupOpen = true
    },
    submitSignup() {
      this.$refs.signupForm.validate(valid => {
        if (!valid || !this.selectedActivity) return
        signupActivity(this.selectedActivity.activityId, this.signupForm).then(() => {
          this.$modal.msgSuccess('报名成功')
          this.signupOpen = false
          this.getList()
          this.getMySignups()
        })
      })
    }
  }
}
</script>
