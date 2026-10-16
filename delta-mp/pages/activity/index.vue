<template>
  <view class="activity-page">
    <view v-if="activities.length" class="activity-list">
      <view v-for="item in activities" :key="item.id" class="activity-item" @click="openActivity(item)">
        <view class="activity-heading">
          <text class="activity-label">平台活动</text>
          <text class="activity-date">{{ formatDate(item.createdAt) }}</text>
        </view>
        <text class="activity-title">{{ item.title }}</text>
        <view class="activity-footer">
          <text class="activity-action">查看详情</text>
          <text class="activity-arrow">›</text>
        </view>
      </view>
    </view>
    <EmptyState v-else text="暂无活动" image="/static/icons/空空如也.svg" />

    <view v-if="selectedActivity" class="detail-mask" @click="selectedActivity = null">
      <view class="detail-panel" @click.stop>
        <view class="detail-header">
          <text class="detail-heading">活动详情</text>
          <text class="detail-close" @click="selectedActivity = null">×</text>
        </view>
        <scroll-view scroll-y class="detail-body">
          <text class="detail-title">{{ selectedActivity.title }}</text>
          <text class="detail-date">{{ formatDate(selectedActivity.createdAt) }}</text>
          <rich-text v-if="selectedActivity.content" class="detail-content" :nodes="selectedActivity.content" />
        </scroll-view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh } from '@dcloudio/uni-app'
import EmptyState from '@/components/EmptyState.vue'
import { getActiveNotices } from '@/api/notice'

const activities = ref([])
const selectedActivity = ref(null)

function formatDate(value) {
  if (!value) return ''
  const date = new Date(String(value).replace(' ', 'T'))
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

async function loadActivities() {
  try {
    const res = await getActiveNotices({ loading: false })
    const list = res.data?.records || res.data || []
    activities.value = list.filter(item => item.type === 'activity')
  } catch (error) {
    activities.value = []
  }
}

function openActivity(item) {
  selectedActivity.value = item
}

onShow(loadActivities)
onPullDownRefresh(async () => {
  await loadActivities()
  uni.stopPullDownRefresh()
})
</script>

<style lang="scss" scoped>
.activity-page {
  min-height: 100vh;
  padding: 24rpx;
  box-sizing: border-box;
  background: #f4f6f8;
}
.activity-list { display: flex; flex-direction: column; gap: 18rpx; }
.activity-item {
  padding: 26rpx;
  border: 1rpx solid #e7eaee;
  border-radius: 12rpx;
  background: #fff;
}
.activity-heading, .activity-footer, .detail-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.activity-label { color: #bf8b2e; font-size: 22rpx; font-weight: 600; }
.activity-date, .detail-date { color: #89919d; font-size: 22rpx; }
.activity-title { display: block; margin: 18rpx 0 22rpx; color: #202733; font-size: 30rpx; font-weight: 600; }
.activity-footer { padding-top: 16rpx; border-top: 1rpx solid #edf0f2; }
.activity-action { color: #697483; font-size: 23rpx; }
.activity-arrow { color: #89919d; font-size: 34rpx; }
.detail-mask { position: fixed; inset: 0; z-index: 20; display: flex; align-items: flex-end; background: rgba(16, 22, 30, .48); }
.detail-panel { display: flex; width: 100%; max-height: 78vh; flex-direction: column; border-radius: 20rpx 20rpx 0 0; background: #fff; }
.detail-header { padding: 26rpx 30rpx; border-bottom: 1rpx solid #edf0f2; }
.detail-heading { color: #202733; font-size: 29rpx; font-weight: 600; }
.detail-close { padding: 0 8rpx; color: #737d89; font-size: 42rpx; }
.detail-body { padding: 30rpx; box-sizing: border-box; }
.detail-title { display: block; margin-bottom: 12rpx; color: #202733; font-size: 34rpx; font-weight: 700; }
.detail-content { display: block; margin-top: 28rpx; color: #39424e; font-size: 27rpx; line-height: 1.7; }
</style>
