<template>
  <div class="app-container">
    <el-form ref="queryForm" :model="queryParams" :inline="true" size="small" v-show="showSearch" label-width="68px">
      <el-form-item label="用户账号" prop="userName">
        <el-input v-model="queryParams.userName" placeholder="请输入用户账号" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="手机号码" prop="phonenumber">
        <el-input v-model="queryParams.phonenumber" placeholder="请输入手机号码" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="用户状态" clearable>
          <el-option label="正常" value="0" />
          <el-option label="停用" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['system:user:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['system:user:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['system:user:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="userList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="用户编号" prop="userId" align="center" width="90" />
      <el-table-column label="用户账号" prop="userName" align="center" :show-overflow-tooltip="true" />
      <el-table-column label="用户昵称" prop="nickName" align="center" :show-overflow-tooltip="true" />
      <el-table-column label="手机号码" prop="phonenumber" align="center" width="120" />
      <el-table-column label="邮箱" prop="email" align="center" :show-overflow-tooltip="true" />
      <el-table-column label="状态" align="center" width="95">
        <template slot-scope="scope">
          <el-switch
            v-model="scope.row.status"
            active-value="0"
            inactive-value="1"
            @change="handleStatusChange(scope.row)"
            v-hasPermi="['system:user:edit']"
          />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="170">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="320">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:user:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-key"
            @click="handleResetPwd(scope.row)"
            v-hasPermi="['system:user:resetPwd']"
          >重置密码</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:user:remove']"
          >删除</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-circle-check"
            @click="handleAuthRole(scope.row)"
            v-hasPermi="['system:user:edit']"
          >分配角色</el-button>
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

    <el-dialog :title="title" :visible.sync="open" width="780px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="用户账号" prop="userName">
              <el-input v-model="form.userName" maxlength="30" placeholder="请输入用户账号" :disabled="form.userId !== undefined" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="用户昵称" prop="nickName">
              <el-input v-model="form.nickName" maxlength="30" placeholder="请输入用户昵称" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.userId === undefined">
            <el-form-item label="密码" prop="password">
              <el-input v-model="form.password" type="password" maxlength="20" show-password placeholder="请输入密码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号码" prop="phonenumber">
              <el-input v-model="form.phonenumber" maxlength="11" placeholder="请输入手机号码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" maxlength="50" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="sex">
              <el-select v-model="form.sex" placeholder="请选择性别" style="width: 100%">
                <el-option label="男" value="0" />
                <el-option label="女" value="1" />
                <el-option label="未知" value="2" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio label="0">正常</el-radio>
                <el-radio label="1">停用</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="身份角色" prop="identityRoleId">
              <el-select v-model="form.identityRoleId" placeholder="请选择身份角色" style="width: 100%">
                <el-option
                  v-for="role in identityRoleOptions"
                  :key="role.roleId"
                  :label="role.roleName + '（' + role.roleKey + '）'"
                  :value="role.roleId"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="岗位" prop="postIds">
              <el-select v-model="form.postIds" multiple placeholder="请选择岗位" style="width: 100%">
                <el-option
                  v-for="post in postOptions"
                  :key="post.postId"
                  :label="post.postName"
                  :value="post.postId"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="部门" prop="deptId">
              <el-select v-model="form.deptId" clearable filterable placeholder="请选择部门" style="width: 100%">
                <el-option
                  v-for="item in deptOptions"
                  :key="item.id"
                  :label="item.label"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" :rows="3" maxlength="500" show-word-limit placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <el-dialog title="重置密码" :visible.sync="openPwd" width="420px" append-to-body>
      <el-form ref="pwdForm" :model="pwdForm" :rules="pwdRules" label-width="90px">
        <el-form-item label="新密码" prop="password">
          <el-input v-model="pwdForm.password" type="password" show-password maxlength="20" placeholder="请输入新密码" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitResetPwd">确 定</el-button>
        <el-button @click="openPwd = false">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addUser, changeUserStatus, delUser, getUser, listUser, resetUserPwd, updateUser } from '@/api/system/user'
import { listRole } from '@/api/system/role'
import { listPost } from '@/api/system/post'
import { listDept } from '@/api/system/dept'

export default {
  name: 'User',
  data() {
    return {
      loading: false,
      showSearch: true,
      total: 0,
      userList: [],
      open: false,
      title: '',
      ids: [],
      single: true,
      multiple: true,
      roleOptions: [],
      identityRoleOptions: [],
      postOptions: [],
      deptOptions: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: undefined,
        phonenumber: undefined,
        status: undefined
      },
      form: {},
      rules: {
        userName: [{ required: true, message: '用户账号不能为空', trigger: 'blur' }],
        nickName: [{ required: true, message: '用户昵称不能为空', trigger: 'blur' }],
        password: [{ required: true, message: '密码不能为空', trigger: 'blur' }],
        email: [{ type: 'email', message: '请输入正确的邮箱地址', trigger: ['blur', 'change'] }],
        phonenumber: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }],
        identityRoleId: [{ required: true, message: '请选择身份角色', trigger: 'change' }]
      },
      openPwd: false,
      pwdForm: {
        userId: undefined,
        password: ''
      },
      pwdRules: {
        password: [{ required: true, message: '新密码不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
    this.loadRoleOptions()
    this.loadPostOptions()
    this.loadDeptOptions()
  },
  methods: {
    getList() {
      this.loading = true
      listUser(this.queryParams).then(res => {
        this.userList = res.rows || []
        this.total = res.total || 0
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    loadRoleOptions() {
      listRole({ pageNum: 1, pageSize: 1000, status: '0' }).then(res => {
        this.roleOptions = res.rows || []
        this.identityRoleOptions = this.roleOptions.filter(role => ['admin', 'common', 'merchant'].includes(role.roleKey))
      })
    },
    loadPostOptions() {
      listPost({ pageNum: 1, pageSize: 1000, status: '0' }).then(res => {
        this.postOptions = res.rows || []
      })
    },
    loadDeptOptions() {
      listDept({ status: '0' }).then(res => {
        const rows = res.data || []
        this.deptOptions = rows.map(item => ({ id: item.deptId, label: item.deptName }))
      })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.userId)
      this.single = selection.length !== 1
      this.multiple = selection.length === 0
    },
    reset() {
      this.form = {
        userId: undefined,
        deptId: undefined,
        userName: '',
        nickName: '',
        password: '',
        phonenumber: '',
        email: '',
        sex: '0',
        status: '0',
        identityRoleId: undefined,
        roleIds: [],
        postIds: [],
        remark: ''
      }
      this.resetForm('form')
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '添加用户'
    },
    handleUpdate(row) {
      this.reset()
      const userId = row.userId || this.ids[0]
      getUser(userId).then(res => {
        this.form = {
          userId: res.data.userId,
          deptId: res.data.deptId,
          userName: res.data.userName,
          nickName: res.data.nickName,
          password: '',
          phonenumber: res.data.phonenumber,
          email: res.data.email,
          sex: res.data.sex || '0',
          status: res.data.status || '0',
          identityRoleId: (res.roleIds && res.roleIds.length) ? res.roleIds[0] : undefined,
          roleIds: res.roleIds || [],
          postIds: res.postIds || [],
          remark: res.data.remark || ''
        }
        this.open = true
        this.title = '修改用户'
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const submitData = Object.assign({}, this.form)
        submitData.roleIds = submitData.identityRoleId ? [submitData.identityRoleId] : []
        if (submitData.userId !== undefined && !submitData.password) {
          delete submitData.password
        }
        const request = submitData.userId !== undefined ? updateUser(submitData) : addUser(submitData)
        request.then(() => {
          this.$modal.msgSuccess(submitData.userId !== undefined ? '修改成功' : '新增成功')
          this.open = false
          this.getList()
        })
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    handleDelete(row) {
      const userIds = row.userId ? [row.userId] : this.ids
      if (userIds.length === 0) {
        return
      }
      this.$modal.confirm('是否确认删除用户编号为“' + userIds.join(',') + '”的数据项？').then(() => {
        return Promise.all(userIds.map(id => delUser(id)))
      }).then(() => {
        this.$modal.msgSuccess('删除成功')
        this.getList()
      }).catch(() => {})
    },
    handleStatusChange(row) {
      const text = row.status === '0' ? '启用' : '停用'
      this.$modal.confirm('确认要“' + text + '”“' + row.userName + '”用户吗？').then(() => {
        return changeUserStatus(row.userId, row.status)
      }).then(() => {
        this.$modal.msgSuccess(text + '成功')
      }).catch(() => {
        row.status = row.status === '0' ? '1' : '0'
      })
    },
    handleResetPwd(row) {
      this.pwdForm = {
        userId: row.userId,
        password: ''
      }
      this.openPwd = true
      this.$nextTick(() => this.resetForm('pwdForm'))
    },
    submitResetPwd() {
      this.$refs.pwdForm.validate(valid => {
        if (!valid) return
        resetUserPwd(this.pwdForm.userId, this.pwdForm.password).then(() => {
          this.$modal.msgSuccess('重置成功')
          this.openPwd = false
        })
      })
    },
    handleAuthRole(row) {
      this.$router.push('/system/user-auth/role/' + row.userId)
    }
  }
}
</script>
