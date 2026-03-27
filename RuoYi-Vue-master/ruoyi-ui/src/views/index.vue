<template>
  <div class="app-container home">
    <el-card class="welcome-card" shadow="never">
      <div class="title">宠物社区平台</div>
      <div class="desc">欢迎使用宠物社区平台后台管理系统</div>
      <div class="meta">
        <el-tag type="success" size="mini">社交匹配</el-tag>
        <el-tag type="warning" size="mini">健康记录</el-tag>
        <el-tag type="danger" size="mini">健康预警</el-tag>
      </div>
    </el-card>

    <el-row :gutter="16" style="margin-top: 16px;">
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="quick-card" shadow="hover">
          <div class="quick-title">宠物档案</div>
          <div class="quick-desc">维护宠物基础信息、标签与状态</div>
          <el-button type="primary" size="mini" @click="$router.push('/pet/info')">进入页面</el-button>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="quick-card" shadow="hover">
          <div class="quick-title">健康记录</div>
          <div class="quick-desc">录入每日健康数据，自动触发预警</div>
          <el-button type="primary" size="mini" @click="goPetPage('/pet/health')">进入页面</el-button>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8">
        <el-card class="quick-card" shadow="hover">
          <div class="quick-title">社交推荐</div>
          <div class="quick-desc">按标签计算匹配度并发送社交邀请</div>
          <el-button type="primary" size="mini" @click="goPetPage('/pet/social')">进入页面</el-button>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
export default {
  name: 'Home',
  computed: {
    hasPet() {
      return this.$store.getters.hasPet
    },
    isAdmin() {
      const roles = this.$store.getters.roles || []
      return roles.includes('admin')
    }
  },
  methods: {
    goPetPage(path) {
      if (!this.isAdmin && !this.hasPet && path !== '/pet/info') {
        this.$message.warning('请先完善宠物档案后再使用该功能')
        this.$router.push('/pet/info')
        return
      }
      this.$router.push(path)
    }
  }
}
</script>

<style scoped>
.home { min-height: calc(100vh - 84px); }
.welcome-card { border-radius: 10px; }
.title { font-size: 24px; font-weight: 700; color: #303133; }
.desc { color: #606266; margin-top: 8px; }
.meta { margin-top: 12px; display: flex; gap: 8px; }
.quick-card { border-radius: 10px; margin-bottom: 16px; }
.quick-title { font-size: 16px; font-weight: 600; color: #303133; }
.quick-desc { color: #909399; margin: 8px 0 12px; min-height: 38px; }
</style>
