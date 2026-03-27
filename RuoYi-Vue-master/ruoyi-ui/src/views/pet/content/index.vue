<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" @tab-click="handleTabChange">
      <el-tab-pane label="内容广场" name="square">
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

        <el-row :gutter="10" class="mb8" v-if="activeTab === 'square'">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">发布内容</el-button>
          </el-col>
          <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
        </el-row>

        <el-table v-loading="loading" :data="contentList">
          <el-table-column label="标题" prop="title" min-width="180" show-overflow-tooltip />
          <el-table-column label="类型" prop="contentType" width="100" align="center" />
          <el-table-column label="宠物" prop="petName" width="120" align="center" />
          <el-table-column label="发布人" prop="creatorName" width="120" align="center" />
          <el-table-column label="标签" min-width="180" show-overflow-tooltip>
            <template slot-scope="scope">
              <el-tag v-for="tag in splitTags(scope.row.tags)" :key="scope.row.contentId + '-' + tag" size="mini" style="margin:2px">{{ tag }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="审核状态" prop="reviewStatus" width="100" align="center">
            <template slot-scope="scope">
              <el-tag :type="reviewTagType(scope.row.reviewStatus)" size="mini">{{ reviewLabel(scope.row.reviewStatus) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="发布时间" width="160" align="center">
            <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
          <el-table-column label="摘要" prop="summary" min-width="200" show-overflow-tooltip />
        </el-table>

        <pagination
          v-show="total > 0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </el-tab-pane>

      <el-tab-pane label="推荐内容" name="recommend">
        <el-alert title="推荐逻辑为基于宠物品种/年龄标签的固定规则匹配，不使用机器学习。" type="info" :closable="false" show-icon style="margin-bottom:12px" />
        <el-table v-loading="recommendLoading" :data="recommendList">
          <el-table-column label="标题" prop="title" min-width="200" show-overflow-tooltip />
          <el-table-column label="类型" prop="contentType" width="100" align="center" />
          <el-table-column label="发布人" prop="creatorName" width="120" align="center" />
          <el-table-column label="推荐原因" prop="recommendReason" min-width="220" show-overflow-tooltip />
          <el-table-column label="标签" min-width="180" show-overflow-tooltip>
            <template slot-scope="scope">
              <el-tag v-for="tag in splitTags(scope.row.tags)" :key="scope.row.contentId + '-r-' + tag" size="mini" type="success" style="margin:2px">{{ tag }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="发布时间" width="160" align="center">
            <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog title="发布宠物内容" :visible.sync="open" width="640px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="发布宠物" prop="petId">
              <el-select v-model="form.petId" placeholder="请选择宠物" style="width:100%" filterable>
                <el-option v-for="pet in myPets" :key="pet.petId" :label="pet.petName + '（' + (pet.breed || '未知品种') + '）'" :value="pet.petId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内容类型" prop="contentType">
              <el-select v-model="form.contentType" placeholder="请选择" style="width:100%">
                <el-option label="经验分享" value="经验分享" />
                <el-option label="求助问答" value="求助问答" />
                <el-option label="日常动态" value="日常动态" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="标题" prop="title">
              <el-input v-model="form.title" maxlength="100" show-word-limit placeholder="请输入标题" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="摘要" prop="summary">
              <el-input v-model="form.summary" type="textarea" :rows="2" maxlength="255" show-word-limit placeholder="请输入摘要" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="正文" prop="contentText">
              <el-input v-model="form.contentText" type="textarea" :rows="5" maxlength="3000" show-word-limit placeholder="请输入正文内容" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="标签" prop="tags">
              <el-input v-model="form.tags" placeholder="多个标签用英文逗号分隔，如：金毛,幼宠,喂养" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="媒体链接">
              <el-input v-model="form.mediaUrl" placeholder="可选，图片/视频 URL" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">发 布</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addContent, listContent, listRecommendedContent } from '@/api/pet/content'
import { listPetInfo } from '@/api/pet/petInfo'
import { mapGetters } from 'vuex'

export default {
  name: 'PetContent',
  data() {
    return {
      activeTab: 'square',
      showSearch: true,
      loading: false,
      recommendLoading: false,
      total: 0,
      contentList: [],
      recommendList: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        reviewStatus: undefined
      },
      open: false,
      myPets: [],
      form: {},
      rules: {
        petId: [{ required: true, message: '请选择发布宠物', trigger: 'change' }],
        contentType: [{ required: true, message: '请选择内容类型', trigger: 'change' }],
        title: [{ required: true, message: '标题不能为空', trigger: 'blur' }],
        summary: [{ required: true, message: '摘要不能为空', trigger: 'blur' }],
        contentText: [{ required: true, message: '正文不能为空', trigger: 'blur' }],
        tags: [{ required: true, message: '标签不能为空', trigger: 'blur' }]
      }
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
    this.getRecommendList()
    this.loadMyPets()
  },
  methods: {
    getList() {
      this.loading = true
      listContent(this.queryParams).then(res => {
        this.contentList = res.rows || []
        this.total = res.total || 0
        this.loading = false
      }).catch(() => { this.loading = false })
    },
    getRecommendList() {
      this.recommendLoading = true
      listRecommendedContent({ pageNum: 1, pageSize: 50 }).then(res => {
        this.recommendList = res.rows || []
        this.recommendLoading = false
      }).catch(() => { this.recommendLoading = false })
    },
    loadMyPets() {
      listPetInfo({ pageNum: 1, pageSize: 100, ownerUserId: this.userId, status: '0' }).then(res => {
        this.myPets = res.rows || []
      })
    },
    handleTabChange() {
      if (this.activeTab === 'square') {
        this.getList()
      } else {
        this.getRecommendList()
      }
    },
    reviewLabel(status) {
      return ({ '0': '待审核', '1': '已通过', '2': '已拒绝' })[status] || '未知'
    },
    reviewTagType(status) {
      return ({ '0': 'warning', '1': 'success', '2': 'danger' })[status] || 'info'
    },
    splitTags(str) {
      if (!str) return []
      return str.split(',').map(s => s.trim()).filter(Boolean)
    },
    reset() {
      this.form = {
        petId: undefined,
        contentType: '经验分享',
        title: '',
        summary: '',
        contentText: '',
        tags: '',
        mediaUrl: ''
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
        addContent(this.form).then(() => {
          this.$modal.msgSuccess('发布成功，待管理员审核')
          this.open = false
          this.getList()
          this.getRecommendList()
        })
      })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    }
  }
}
</script>
