<template>
  <div class="page-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>活动专栏</span>
          <el-button type="primary" @click="openDialog()">新增活动</el-button>
        </div>
      </template>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="title" label="活动标题" min-width="220" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '已发布' : '草稿' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-popconfirm title="确认删除此活动？" @confirm="handleDelete(row.id)">
              <template #reference><el-button link type="danger">删除</el-button></template>
            </el-popconfirm>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无活动" />
        </template>
      </el-table>
      <Pagination :total="total" v-model:page="query.pageNum" v-model:limit="query.pageSize" @pagination="fetchData" />
    </el-card>

    <el-dialog v-model="dialogVisible" :title="editingId ? '编辑活动' : '新增活动'" width="680px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="活动标题" prop="title">
          <el-input v-model="form.title" maxlength="100" show-word-limit placeholder="请输入活动标题" />
        </el-form-item>
        <el-form-item label="活动内容" prop="content">
          <RichTextEditor v-model="form.content" />
        </el-form-item>
        <el-form-item label="发布状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="发布" inactive-text="草稿" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import Pagination from '@/components/Pagination.vue'
import RichTextEditor from '@/components/RichTextEditor.vue'
import { addNotice, deleteNotice, getNoticeList, updateNotice } from '@/api/system'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10, type: 'activity' })
const dialogVisible = ref(false)
const editingId = ref(null)
const submitting = ref(false)
const formRef = ref(null)
const emptyForm = () => ({ title: '', content: '', type: 'activity', status: 1, popupDisplay: 0 })
const form = reactive(emptyForm())
const rules = {
  title: [{ required: true, message: '请输入活动标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入活动内容', trigger: 'blur' }]
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getNoticeList(query)
    list.value = res.data.records || []
    total.value = Number(res.data.total || 0)
  } finally {
    loading.value = false
  }
}

function openDialog(row) {
  editingId.value = row?.id || null
  Object.assign(form, emptyForm(), row || {})
  form.type = 'activity'
  form.popupDisplay = 0
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    const data = { ...form, type: 'activity', popupDisplay: 0 }
    if (editingId.value) await updateNotice({ ...data, id: editingId.value })
    else await addNotice(data)
    ElMessage.success('活动已保存')
    dialogVisible.value = false
    await fetchData()
  } finally {
    submitting.value = false
  }
}

async function handleDelete(id) {
  try {
    await deleteNotice(id)
    ElMessage.success('活动已删除')
    await fetchData()
  } catch (e) {
    // 删除失败的错误已由请求拦截器统一提示，这里仅避免未处理的 Promise rejection
  }
}

onMounted(fetchData)
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
