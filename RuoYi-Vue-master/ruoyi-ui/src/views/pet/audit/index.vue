<template>
  <div class="app-container">
    <el-tabs v-model="tabName" @tab-click="handleTabChange">
      <el-tab-pane label="内容审核" name="content">
        <el-form :model="contentQuery" ref="contentQueryForm" size="small" :inline="true" v-show="showSearch">
          <el-form-item label="审核状态" prop="reviewStatus">
            <el-select v-model="contentQuery.reviewStatus" clearable placeholder="全部">
              <el-option label="待审核" value="0" />
              <el-option label="已通过" value="1" />
              <el-option label="已拒绝" value="2" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" size="mini" @click="getContentList">搜索</el-button>
            <el-button icon="el-icon-refresh" size="mini" @click="resetContentQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-table v-loading="contentLoading" :data="contentList">
          <el-table-column label="标题" prop="title" min-width="180" show-overflow-tooltip />
          <el-table-column label="发布人" prop="creatorName" width="120" align="center" />
          <el-table-column label="宠物" prop="petName" width="120" align="center" />
          <el-table-column label="类型" prop="contentType" width="100" align="center" />
          <el-table-column label="状态" width="100" align="center">
            <template slot-scope="scope">
              <el-tag :type="reviewTagType(scope.row.reviewStatus)" size="mini">{{ reviewLabel(scope.row.reviewStatus) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="提交时间" width="160" align="center">
            <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="180" align="center">
            <template slot-scope="scope">
              <el-button v-if="scope.row.reviewStatus === '0'" size="mini" type="text" icon="el-icon-check" @click="openContentReview(scope.row, '1')">通过</el-button>
              <el-button v-if="scope.row.reviewStatus === '0'" size="mini" type="text" icon="el-icon-close" @click="openContentReview(scope.row, '2')">拒绝</el-button>
              <span v-if="scope.row.reviewStatus !== '0'">{{ scope.row.reviewBy || '-' }}</span>
            </template>
          </el-table-column>
        </el-table>

        <pagination
          v-show="contentTotal > 0"
          :total="contentTotal"
          :page.sync="contentQuery.pageNum"
          :limit.sync="contentQuery.pageSize"
          @pagination="getContentList"
        />
      </el-tab-pane>

      <el-tab-pane label="活动审核" name="activity">
        <el-form :model="activityQuery" ref="activityQueryForm" size="small" :inline="true" v-show="showSearch">
          <el-form-item label="审核状态" prop="reviewStatus">
            <el-select v-model="activityQuery.reviewStatus" clearable placeholder="全部">
              <el-option label="待审核" value="0" />
              <el-option label="已通过" value="1" />
              <el-option label="已拒绝" value="2" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" size="mini" @click="getActivityList">搜索</el-button>
            <el-button icon="el-icon-refresh" size="mini" @click="resetActivityQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-table v-loading="activityLoading" :data="activityList">
          <el-table-column label="活动标题" prop="title" min-width="180" show-overflow-tooltip />
          <el-table-column label="发起人" prop="creatorName" width="120" align="center" />
          <el-table-column label="类型" prop="activityType" width="100" align="center" />
          <el-table-column label="地点" prop="location" min-width="150" show-overflow-tooltip />
          <el-table-column label="时间" min-width="220" align="center">
            <template slot-scope="scope">{{ parseTime(scope.row.startTime) }} ~ {{ parseTime(scope.row.endTime) }}</template>
          </el-table-column>
          <el-table-column label="状态" width="100" align="center">
            <template slot-scope="scope">
              <el-tag :type="reviewTagType(scope.row.reviewStatus)" size="mini">{{ reviewLabel(scope.row.reviewStatus) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" align="center">
            <template slot-scope="scope">
              <el-button v-if="scope.row.reviewStatus === '0'" size="mini" type="text" icon="el-icon-check" @click="openActivityReview(scope.row, '1')">通过</el-button>
              <el-button v-if="scope.row.reviewStatus === '0'" size="mini" type="text" icon="el-icon-close" @click="openActivityReview(scope.row, '2')">拒绝</el-button>
              <span v-if="scope.row.reviewStatus !== '0'">{{ scope.row.reviewBy || '-' }}</span>
            </template>
          </el-table-column>
        </el-table>

        <pagination
          v-show="activityTotal > 0"
          :total="activityTotal"
          :page.sync="activityQuery.pageNum"
          :limit.sync="activityQuery.pageSize"
          @pagination="getActivityList"
        />
      </el-tab-pane>
    </el-tabs>

    <el-dialog :title="reviewDialogTitle" :visible.sync="reviewOpen" width="520px" append-to-body>
      <el-form ref="reviewForm" :model="reviewForm" :rules="reviewRules" label-width="90px">
        <el-form-item label="审核结果" prop="reviewStatus">
          <el-radio-group v-model="reviewForm.reviewStatus">
            <el-radio label="1">通过</el-radio>
            <el-radio label="2">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核备注" prop="reviewNote">
          <el-input v-model="reviewForm.reviewNote" type="textarea" :rows="4" maxlength="500" show-word-limit placeholder="请输入审核备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitReview">确 定</el-button>
        <el-button @click="reviewOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listAuditActivity, listAuditContent, reviewActivity, reviewContent } from '@/api/pet/audit'

export default {
  name: 'PetAudit',
  data() {
    return {
      tabName: 'content',
      showSearch: true,
      contentLoading: false,
      activityLoading: false,
      contentTotal: 0,
      activityTotal: 0,
      contentList: [],
      activityList: [],
      contentQuery: {
        pageNum: 1,
        pageSize: 10,
        reviewStatus: '0'
      },
      activityQuery: {
        pageNum: 1,
        pageSize: 10,
        reviewStatus: '0'
      },
      reviewOpen: false,
      reviewDialogTitle: '审核',
      reviewTargetType: 'content',
      reviewTargetId: undefined,
      reviewForm: {
        reviewStatus: '1',
        reviewNote: ''
      },
      reviewRules: {
        reviewStatus: [{ required: true, message: '请选择审核结果', trigger: 'change' }],
        reviewNote: [{ required: true, message: '请填写审核备注', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getContentList()
    this.getActivityList()
  },
  methods: {
    handleTabChange() {
      if (this.tabName === 'content') {
        this.getContentList()
      } else {
        this.getActivityList()
      }
    },
    reviewLabel(status) {
      return ({ '0': '待审核', '1': '已通过', '2': '已拒绝' })[status] || '未知'
    },
    reviewTagType(status) {
      return ({ '0': 'warning', '1': 'success', '2': 'danger' })[status] || 'info'
    },
    getContentList() {
      this.contentLoading = true
      listAuditContent(this.contentQuery).then(res => {
        this.contentList = res.rows || []
        this.contentTotal = res.total || 0
        this.contentLoading = false
      }).catch(() => { this.contentLoading = false })
    },
    getActivityList() {
      this.activityLoading = true
      listAuditActivity(this.activityQuery).then(res => {
        this.activityList = res.rows || []
        this.activityTotal = res.total || 0
        this.activityLoading = false
      }).catch(() => { this.activityLoading = false })
    },
    resetContentQuery() {
      this.resetForm('contentQueryForm')
      this.contentQuery.pageNum = 1
      this.getContentList()
    },
    resetActivityQuery() {
      this.resetForm('activityQueryForm')
      this.activityQuery.pageNum = 1
      this.getActivityList()
    },
    openContentReview(row, status) {
      this.reviewTargetType = 'content'
      this.reviewTargetId = row.contentId
      this.reviewDialogTitle = '内容审核'
      this.reviewForm = { reviewStatus: status, reviewNote: '' }
      this.reviewOpen = true
      this.$nextTick(() => this.resetForm('reviewForm'))
    },
    openActivityReview(row, status) {
      this.reviewTargetType = 'activity'
      this.reviewTargetId = row.activityId
      this.reviewDialogTitle = '活动审核'
      this.reviewForm = { reviewStatus: status, reviewNote: '' }
      this.reviewOpen = true
      this.$nextTick(() => this.resetForm('reviewForm'))
    },
    submitReview() {
      this.$refs.reviewForm.validate(valid => {
        if (!valid || !this.reviewTargetId) return
        const action = this.reviewTargetType === 'content' ? reviewContent : reviewActivity
        action(this.reviewTargetId, this.reviewForm).then(() => {
          this.$modal.msgSuccess('审核成功')
          this.reviewOpen = false
          this.getContentList()
          this.getActivityList()
        })
      })
    }
  }
}
</script>
