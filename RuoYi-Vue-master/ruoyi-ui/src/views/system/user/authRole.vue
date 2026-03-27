<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>为用户分配角色</span>
      </div>

      <el-descriptions :column="3" border>
        <el-descriptions-item label="用户账号">{{ user.userName }}</el-descriptions-item>
        <el-descriptions-item label="用户昵称">{{ user.nickName }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ user.phonenumber || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-alert
        title="系统采用 RBAC：请为用户选择一个主身份（普通用户/管理员/服务商家）。"
        type="info"
        :closable="false"
        show-icon
        style="margin: 16px 0;"
      />

      <el-table ref="roleTable" v-loading="loading" :data="roleList" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="50" align="center" />
        <el-table-column label="角色ID" prop="roleId" width="90" align="center" />
        <el-table-column label="角色名称" prop="roleName" align="center" />
        <el-table-column label="权限字符" prop="roleKey" align="center" />
        <el-table-column label="状态" align="center" width="120">
          <template slot-scope="scope">
            <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'" size="mini">
              {{ scope.row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <div style="margin-top: 16px; text-align: right;">
        <el-button @click="close">返 回</el-button>
        <el-button type="primary" @click="submitAuthRole">保 存</el-button>
      </div>
    </el-card>
  </div>
</template>

<script>
import { getAuthRole, updateAuthRole } from '@/api/system/user'

export default {
  name: 'AuthRole',
  data() {
    return {
      loading: false,
      userId: undefined,
      user: {},
      roleList: [],
      roleIds: []
    }
  },
  created() {
    this.userId = this.$route.params && this.$route.params.userId
    this.getInfo()
  },
  methods: {
    getInfo() {
      if (!this.userId) {
        this.$modal.msgError('缺少用户ID')
        return
      }
      this.loading = true
      getAuthRole(this.userId).then(res => {
        this.user = res.user || {}
        this.roleList = (res.roles || []).filter(role => role.status === '0' && ['admin', 'common', 'merchant'].includes(role.roleKey))
        this.roleIds = (res.roles || []).filter(role => role.flag).map(role => role.roleId)
        this.$nextTick(() => {
          this.toggleSelectionByRoleIds(this.roleIds)
        })
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    toggleSelectionByRoleIds(roleIds) {
      const selected = new Set(roleIds || [])
      this.roleList.forEach(row => {
        if (selected.has(row.roleId)) {
          this.$refs.roleTable && this.$refs.roleTable.toggleRowSelection(row, true)
        }
      })
    },
    handleSelectionChange(selection) {
      // Restrict to one role so identity stays clear and aligned with requirements.
      if (selection.length > 1) {
        const latest = selection[selection.length - 1]
        this.$refs.roleTable && this.$refs.roleTable.clearSelection()
        this.$refs.roleTable && this.$refs.roleTable.toggleRowSelection(latest, true)
        this.roleIds = [latest.roleId]
      } else {
        this.roleIds = selection.map(item => item.roleId)
      }
    },
    submitAuthRole() {
      if (!this.roleIds.length) {
        this.$modal.msgError('请至少选择一个角色')
        return
      }
      updateAuthRole({ userId: this.userId, roleIds: this.roleIds.join(',') }).then(() => {
        this.$modal.msgSuccess('分配角色成功')
        this.close()
      })
    },
    close() {
      this.$tab.closeOpenPage('/system/user')
    }
  }
}
</script>
