<template>
  <div class="app-container social-page">
    <el-row :gutter="16" class="stats-row">
      <el-col :xs="12" :sm="12" :md="6" v-for="item in statCards" :key="item.label">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-value">{{ item.value }}</div>
          <div class="stat-label">{{ item.label }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="社交推荐" name="match">
        <el-card class="match-header-card" shadow="never">
          <el-row :gutter="16" type="flex" align="middle" class="header-row">
            <el-col :xs="24" :sm="24" :md="10" :lg="8">
              <div class="pet-picker">
                <span class="picker-label">当前账号名下宠物</span>
                <el-select
                  v-model="currentPetId"
                  placeholder="请选择要匹配的宠物"
                  filterable
                  style="width:100%"
                  @change="onPetChange"
                >
                  <el-option
                    v-for="pet in myPets"
                    :key="pet.petId"
                    :label="pet.petName + ' (' + (pet.breed || '未知品种') + ')'"
                    :value="pet.petId"
                  />
                </el-select>
              </div>
            </el-col>
            <el-col :xs="24" :sm="24" :md="4" :lg="4">
              <el-button
                type="primary"
                icon="el-icon-star-on"
                :loading="matchLoading"
                :disabled="!currentPetId"
                style="width:100%"
                @click="startMatch"
              >开始匹配</el-button>
            </el-col>
            <el-col :xs="24" :sm="24" :md="10" :lg="12" v-if="currentPet">
              <div class="current-pet-summary">
                <span>当前宠物：<strong>{{ currentPet.petName }}</strong></span>
                <span>品种：{{ currentPet.breed || '未知品种' }}</span>
                <span>标签：</span>
                <el-tag v-for="tag in currentTags" :key="tag" size="mini" type="info" style="margin-right:4px">{{ tag }}</el-tag>
              </div>
            </el-col>
          </el-row>
        </el-card>

        <el-empty v-if="!myPets.length" description="当前账号下暂无宠物档案，请先新增宠物" />
        <el-empty v-else-if="!matchLoading && matchList.length === 0 && matched" description="暂无匹配结果，请尝试更换宠物或完善标签" />

        <div v-if="matchList.length > 0" class="match-content">
          <div class="match-summary">共找到 {{ matchList.length }} 个可邀请对象，匹配分数越高表示共同标签越多。</div>
          <el-row :gutter="16">
            <el-col v-for="pet in matchList" :key="pet.petId" :xs="24" :sm="12" :md="8" :lg="6" style="margin-bottom:16px">
              <el-card class="pet-match-card" shadow="hover">
                <div class="card-avatar">
                  <div class="avatar-placeholder">
                    <i class="el-icon-picture-outline" style="font-size:40px;color:#dcdfe6"></i>
                  </div>
                  <el-tag :type="scoreType(pet.matchScore)" class="score-badge" size="small">匹配 {{ pet.matchScore }}%</el-tag>
                </div>
                <div class="card-info">
                  <div class="pet-name">{{ pet.petName }}</div>
                  <div class="pet-meta">
                    <span>{{ pet.breed || '未知品种' }}</span>
                    <span v-if="pet.ageMonth"> · {{ monthToAge(pet.ageMonth) }}</span>
                    <span> · 主人ID {{ pet.ownerUserId }}</span>
                  </div>
                </div>
                <div class="card-tags" v-if="pet.matchedTags">
                  <div class="tag-section-label">命中标签</div>
                  <el-tag v-for="tag in toTagArray(pet.matchedTags)" :key="'m-' + tag" type="success" size="mini" style="margin:2px">{{ tag }}</el-tag>
                </div>
                <div class="card-tags" v-if="pet.socialTags">
                  <div class="tag-section-label">全部标签</div>
                  <el-tag v-for="tag in toTagArray(pet.socialTags)" :key="'s-' + tag" type="info" size="mini" style="margin:2px">{{ tag }}</el-tag>
                </div>
                <div style="margin:10px 0 8px">
                  <el-progress :percentage="pet.matchScore || 0" :color="scoreColor(pet.matchScore)" :stroke-width="8" />
                </div>
                <div class="card-footer">
                  <el-button type="primary" size="small" icon="el-icon-position" :loading="sendingId === pet.petId" @click="openInviteDialog(pet)" style="width:100%">发送社交邀请</el-button>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <el-tab-pane label="邀请管理" name="history">
        <el-table :data="historyList" v-loading="historyLoading">
          <el-table-column label="邀请方向" min-width="120">
            <template slot-scope="scope">
              <el-tag :type="scope.row.receiverUserId === userId ? 'warning' : 'info'" size="mini">
                {{ scope.row.receiverUserId === userId ? '我收到的' : '我发出的' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="双方宠物" min-width="170">
            <template slot-scope="scope">{{ scope.row.initiatorPetName }} → {{ scope.row.receiverPetName }}</template>
          </el-table-column>
          <el-table-column label="邀请类型" prop="inviteType" min-width="100" />
          <el-table-column label="活动时间" min-width="160">
            <template slot-scope="scope">{{ parseTime(scope.row.eventTime || scope.row.inviteTime) }}</template>
          </el-table-column>
          <el-table-column label="地点" prop="eventLocation" min-width="120" show-overflow-tooltip />
          <el-table-column label="留言" prop="inviteMessage" min-width="160" show-overflow-tooltip />
          <el-table-column label="状态" min-width="100">
            <template slot-scope="scope">
              <el-tag :type="statusTagType(scope.row.status)" size="mini">{{ statusLabel(scope.row.status) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" min-width="260">
            <template slot-scope="scope">
              <el-button v-if="scope.row.receiverUserId === userId && scope.row.status === '1'" size="mini" type="success" @click="respondInvite(scope.row, '2')">接受</el-button>
              <el-button v-if="scope.row.receiverUserId === userId && scope.row.status === '1'" size="mini" type="danger" @click="respondInvite(scope.row, '3')">拒绝</el-button>
              <el-button v-if="scope.row.status === '2' && !scope.row.friendLinked" size="mini" type="primary" plain @click="addFriend(scope.row)">添加好友</el-button>
              <el-tag v-if="scope.row.status === '2' && scope.row.friendLinked" size="mini" type="success">已是好友</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="好友列表" name="friends">
        <el-table :data="friendList" v-loading="friendLoading">
          <el-table-column label="我的宠物" prop="petName" min-width="140" />
          <el-table-column label="好友宠物" prop="friendPetName" min-width="140" />
          <el-table-column label="好友品种" prop="friendBreed" min-width="120" />
          <el-table-column label="好友主人" prop="friendUserName" min-width="120" />
          <el-table-column label="成为好友时间" min-width="160">
            <template slot-scope="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="活跃排行" name="rank">
        <el-table :data="rankList" v-loading="rankLoading">
          <el-table-column label="排名" width="80" align="center">
            <template slot-scope="scope">{{ scope.$index + 1 }}</template>
          </el-table-column>
          <el-table-column label="宠物" prop="petName" min-width="120" />
          <el-table-column label="品种" prop="breed" min-width="120" />
          <el-table-column label="主人" prop="ownerName" min-width="120" />
          <el-table-column label="成功互动次数" prop="successInteractionCount" min-width="120" />
          <el-table-column label="好友数量" prop="friendCount" min-width="100" />
          <el-table-column label="社交活跃度" prop="socialActivityScore" min-width="100">
            <template slot-scope="scope">
              <el-tag type="danger" size="mini">{{ scope.row.socialActivityScore }}</el-tag>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog title="发送社交邀请" :visible.sync="inviteDialogVisible" width="520px" append-to-body>
      <el-form ref="inviteForm" :model="inviteForm" :rules="inviteRules" label-width="90px">
        <el-form-item label="邀请对象">
          <el-input :value="selectedTarget ? selectedTarget.petName : ''" disabled />
        </el-form-item>
        <el-form-item label="邀请类型" prop="inviteType">
          <el-select v-model="inviteForm.inviteType" style="width:100%">
            <el-option label="线下见面" value="线下见面" />
            <el-option label="一起遛宠" value="一起遛宠" />
            <el-option label="宠友聚会" value="宠友聚会" />
            <el-option label="经验交流" value="经验交流" />
          </el-select>
        </el-form-item>
        <el-form-item label="活动时间" prop="eventTime">
          <el-date-picker v-model="inviteForm.eventTime" type="datetime" value-format="yyyy-MM-dd HH:mm:ss" style="width:100%" />
        </el-form-item>
        <el-form-item label="活动地点" prop="eventLocation">
          <el-input v-model="inviteForm.eventLocation" placeholder="请输入约定地点" />
        </el-form-item>
        <el-form-item label="邀请留言">
          <el-input v-model="inviteForm.inviteMessage" type="textarea" :rows="3" placeholder="请输入留言" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="inviteDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="sendingId === (selectedTarget && selectedTarget.petId)" @click="submitInvite">发 送</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import {
  addSocialFriend,
  getSocialMatchList,
  getSocialStats,
  listSocialFriends,
  listSocialHistory,
  listSocialRank,
  respondSocialInvite,
  sendSocialInvite
} from '@/api/social/match'
import { listPetInfo } from '@/api/pet/petInfo'

export default {
  name: 'SocialMatch',
  data() {
    return {
      activeTab: 'match',
      myPets: [],
      currentPetId: undefined,
      currentPet: null,
      currentTags: [],
      matchList: [],
      matchLoading: false,
      matched: false,
      sendingId: null,
      historyList: [],
      historyLoading: false,
      friendList: [],
      friendLoading: false,
      rankList: [],
      rankLoading: false,
      stats: {
        successInteractionCount: 0,
        pendingReceivedCount: 0,
        pendingSentCount: 0,
        friendCount: 0,
        socialActivityScore: 0
      },
      inviteDialogVisible: false,
      selectedTarget: null,
      inviteForm: {
        inviteType: '线下见面',
        eventTime: '',
        eventLocation: '',
        inviteMessage: ''
      },
      inviteRules: {
        inviteType: [{ required: true, message: '请选择邀请类型', trigger: 'change' }],
        eventTime: [{ required: true, message: '请选择活动时间', trigger: 'change' }],
        eventLocation: [{ required: true, message: '请输入活动地点', trigger: 'blur' }]
      }
    }
  },
  computed: {
    ...mapGetters(['id']),
    userId() {
      return Number(this.id)
    },
    statCards() {
      return [
        { label: '成功互动次数', value: this.stats.successInteractionCount || 0 },
        { label: '待处理邀请', value: this.stats.pendingReceivedCount || 0 },
        { label: '好友数量', value: this.stats.friendCount || 0 },
        { label: '社交活跃度', value: this.stats.socialActivityScore || 0 }
      ]
    }
  },
  created() {
    this.loadMyPets()
    this.refreshSocialData()
  },
  methods: {
    loadMyPets() {
      listPetInfo({ pageNum: 1, pageSize: 100, ownerUserId: this.userId }).then(res => {
        this.myPets = res.rows || []
        if (this.myPets.length && !this.currentPetId) {
          this.currentPetId = this.myPets[0].petId
          this.onPetChange(this.currentPetId)
        }
      })
    },
    refreshSocialData() {
      this.loadStats()
      this.loadHistory()
      this.loadFriends()
      this.loadRank()
    },
    loadStats() {
      getSocialStats().then(res => {
        this.stats = res.data || this.stats
      })
    },
    loadHistory() {
      this.historyLoading = true
      listSocialHistory({ pageNum: 1, pageSize: 100 }).then(res => {
        this.historyList = res.rows || []
        this.historyLoading = false
      }).catch(() => { this.historyLoading = false })
    },
    loadFriends() {
      this.friendLoading = true
      listSocialFriends({ pageNum: 1, pageSize: 100 }).then(res => {
        this.friendList = res.rows || []
        this.friendLoading = false
      }).catch(() => { this.friendLoading = false })
    },
    loadRank() {
      this.rankLoading = true
      listSocialRank({ pageNum: 1, pageSize: 50 }).then(res => {
        this.rankList = res.rows || []
        this.rankLoading = false
      }).catch(() => { this.rankLoading = false })
    },
    onPetChange(petId) {
      this.currentPet = this.myPets.find(p => p.petId === petId) || null
      this.currentTags = this.currentPet && this.currentPet.socialTags
        ? this.currentPet.socialTags.split(',').map(t => t.trim()).filter(Boolean)
        : []
      this.matchList = []
      this.matched = false
    },
    startMatch() {
      if (!this.currentPetId) return
      this.matchLoading = true
      this.matched = false
      getSocialMatchList(this.currentPetId).then(res => {
        this.matchList = (res.data || []).filter(item => Number(item.ownerUserId) !== this.userId)
        this.matched = true
        this.matchLoading = false
      }).catch(() => { this.matchLoading = false })
    },
    toTagArray(str) {
      if (!str) return []
      return str.split(',').map(t => t.trim()).filter(Boolean)
    },
    scoreType(score) {
      if (score >= 80) return 'success'
      if (score >= 60) return 'warning'
      return 'danger'
    },
    scoreColor(score) {
      if (score >= 80) return '#67c23a'
      if (score >= 60) return '#e6a23c'
      return '#f56c6c'
    },
    monthToAge(ageMonth) {
      if (!ageMonth && ageMonth !== 0) return ''
      if (ageMonth < 12) return ageMonth + '个月'
      return (ageMonth / 12).toFixed(ageMonth % 12 === 0 ? 0 : 1) + '岁'
    },
    statusLabel(status) {
      return ({ '0': '待发送', '1': '已发送', '2': '已接受', '3': '已拒绝' })[status] || '未知'
    },
    statusTagType(status) {
      return ({ '0': 'info', '1': 'warning', '2': 'success', '3': 'danger' })[status] || 'info'
    },
    resetInviteForm() {
      this.inviteForm = {
        inviteType: '线下见面',
        eventTime: '',
        eventLocation: '',
        inviteMessage: ''
      }
      this.resetForm('inviteForm')
    },
    openInviteDialog(pet) {
      if (!this.currentPet) {
        this.$modal.msgWarning('请先选择当前账号名下宠物')
        return
      }
      this.selectedTarget = pet
      this.resetInviteForm()
      this.inviteDialogVisible = true
    },
    submitInvite() {
      this.$refs.inviteForm.validate(valid => {
        if (!valid || !this.selectedTarget || !this.currentPet) return
        this.sendingId = this.selectedTarget.petId
        sendSocialInvite({
          initiatorPetId: this.currentPetId,
          receiverPetId: this.selectedTarget.petId,
          matchScore: this.selectedTarget.matchScore,
          matchedTags: this.selectedTarget.matchedTags,
          status: '1',
          inviteType: this.inviteForm.inviteType,
          eventTime: this.inviteForm.eventTime,
          eventLocation: this.inviteForm.eventLocation,
          inviteMessage: this.inviteForm.inviteMessage
        }).then(() => {
          this.$modal.msgSuccess(`已向 ${this.selectedTarget.petName} 发送社交邀请`)
          this.inviteDialogVisible = false
          this.refreshSocialData()
        }).catch(() => {
          this.$modal.msgError('发送失败，请稍后重试')
        }).finally(() => {
          this.sendingId = null
        })
      })
    },
    respondInvite(row, status) {
      const actionText = status === '2' ? '接受' : '拒绝'
      this.$modal.confirm(`确认${actionText}这条社交邀请吗？`).then(() => {
        return respondSocialInvite(row.matchId, { status })
      }).then(() => {
        this.$modal.msgSuccess(`${actionText}成功`)
        this.refreshSocialData()
      }).catch(() => {})
    },
    addFriend(row) {
      this.$modal.confirm('确认将本次成功互动加入好友列表吗？').then(() => {
        return addSocialFriend(row.matchId)
      }).then(() => {
        this.$modal.msgSuccess('添加好友成功')
        this.refreshSocialData()
      }).catch(() => {})
    }
  }
}
</script>

<style scoped>
.social-page {
  padding-bottom: 16px;
}

.stats-row {
  margin-bottom: 16px;
}

.stat-card {
  text-align: center;
  border-radius: 10px;
}

.stat-value {
  font-size: 28px;
  line-height: 1.2;
  font-weight: 700;
  color: #1f2d3d;
}

.stat-label {
  margin-top: 6px;
  color: #909399;
  font-size: 13px;
}

.match-header-card {
  margin-bottom: 12px;
}

.match-header-card .el-card__body {
  padding: 14px 20px;
}

.header-row {
  row-gap: 12px;
}

.pet-picker {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.picker-label {
  color: #606266;
  font-size: 14px;
}

.current-pet-summary {
  color: #606266;
  font-size: 13px;
  line-height: 1.8;
}

.match-content {
  margin-top: 16px;
}

.match-summary {
  margin-bottom: 12px;
  color: #909399;
  font-size: 13px;
}

.pet-match-card {
  border-radius: 8px;
  transition: transform 0.2s;
}

.pet-match-card:hover {
  transform: translateY(-3px);
}

.card-avatar {
  position: relative;
  text-align: center;
  padding: 12px 0 6px;
}

.avatar-placeholder {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  border: 2px solid #ebeef5;
}

.score-badge {
  position: absolute;
  top: 8px;
  right: 8px;
}

.card-info {
  text-align: center;
  margin-bottom: 8px;
}

.pet-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.pet-meta {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

.card-tags {
  margin-bottom: 6px;
}

.tag-section-label {
  font-size: 11px;
  color: #c0c4cc;
  margin-bottom: 3px;
}

.card-footer {
  margin-top: 10px;
}
</style>
