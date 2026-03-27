<template>
  <div class="app-container">
    <!-- 搜索栏 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
      <el-form-item label="处理状态" prop="processStatus">
        <el-select v-model="queryParams.processStatus" placeholder="全部" clearable>
          <el-option label="未处理" value="0" />
          <el-option label="已处理" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item label="预警级别" prop="alertLevel">
        <el-select v-model="queryParams.alertLevel" placeholder="全部" clearable>
          <el-option label="提示" value="1" />
          <el-option label="预警" value="2" />
          <el-option label="严重" value="3" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="alertList">
      <el-table-column label="预警ID" prop="alertId" width="80" align="center" />
      <el-table-column label="宠物ID" prop="petId" width="80" align="center" />
      <el-table-column label="预警类型" prop="alertType" align="center" width="100" />
      <el-table-column label="预警级别" prop="alertLevel" align="center" width="90">
        <template slot-scope="scope">
          <el-tag :type="levelType(scope.row.alertLevel)" size="mini">{{ levelLabel(scope.row.alertLevel) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="预警内容" prop="alertContent" align="center" show-overflow-tooltip />
      <el-table-column label="预警时间" prop="alertTime" align="center" width="160">
        <template slot-scope="scope">{{ parseTime(scope.row.alertTime) }}</template>
      </el-table-column>
      <el-table-column label="处理状态" prop="processStatus" align="center" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.processStatus === '0' ? 'danger' : 'success'" size="mini">
            {{ scope.row.processStatus === '0' ? '未处理' : '已处理' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="处理备注" prop="processNote" align="center" show-overflow-tooltip />
      <el-table-column label="操作" align="center" width="130">
        <template slot-scope="scope">
          <el-button
            v-if="scope.row.processStatus === '0'"
            size="mini" type="text" icon="el-icon-check"
            @click="handleProcess(scope.row)"
          >标记已处理</el-button>
          <span v-else class="processed-text">已处理</span>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <!-- 处理预警对话框 -->
    <el-dialog title="标记处理" :visible.sync="processOpen" width="480px" append-to-body>
      <el-form ref="processForm" :model="processForm" label-width="80px">
        <el-form-item label="预警内容">
          <span>{{ processForm.alertContent }}</span>
        </el-form-item>
        <el-form-item label="处理备注">
          <el-input v-model="processForm.processNote" type="textarea" :rows="3" placeholder="请填写处理备注（选填）" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitProcess">确 定</el-button>
        <el-button @click="processOpen = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listHealthAlert, processAlert } from '@/api/pet/alert'

export default {
  name: 'HealthAlert',
  data() {
    return {
      loading: true,
      total: 0,
      alertList: [],
      showSearch: true,
      processOpen: false,
      queryParams: { pageNum: 1, pageSize: 10, processStatus: undefined, alertLevel: undefined },
      processForm: { alertId: undefined, alertContent: '', processNote: '' }
    }
  },
  created() { this.getList() },
  methods: {
    getList() {
      this.loading = true
      listHealthAlert(this.queryParams).then(res => {
        this.alertList = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    levelType(level) { return level === 1 || level === '1' ? 'info' : level === 2 || level === '2' ? 'warning' : 'danger' },
    levelLabel(level) { return level === 1 || level === '1' ? '提示' : level === 2 || level === '2' ? '预警' : '严重' },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    handleProcess(row) {
      this.processForm = { alertId: row.alertId, alertContent: row.alertContent, processNote: '' }
      this.processOpen = true
    },
    submitProcess() {
      processAlert(this.processForm.alertId, { processNote: this.processForm.processNote }).then(() => {
        this.$modal.msgSuccess('处理成功')
        this.processOpen = false
        this.getList()
      })
    }
  }
}
</script>

<style scoped>
.processed-text { color: #67c23a; font-size: 12px; }
</style>
