<template>
  <view class="home-page tab-page">
    <scroll-view scroll-y class="home-scroll tab-page-scroll" :show-scrollbar="false">
      <!-- 顶部特战品牌识别栏 -->
      <view class="header-brand-bar">
        <view class="brand-left">
          <text class="brand-sub">DELTA FORCE OPS</text>
          <text class="brand-main">三角洲特战接单中心</text>
        </view>
        <view class="brand-guarantee-pill">
          <text class="pill-dot">●</text>
          <text class="pill-text">纯手打 · 掉装包赔</text>
        </view>
      </view>

      <!-- 搜索栏 -->
      <view class="search-bar" @click="goSearch">
        <view class="search-inner">
          <text class="search-icon">⌕</text>
          <text class="search-placeholder">搜索地图、保底收益、统帅排位、特战干员...</text>
        </view>
      </view>

      <!-- 战术特色轮播图 / 无轮播图时的战术指挥部展示卡 -->
      <swiper v-if="banners.length" class="banner" :autoplay="true" :interval="4000" circular indicator-dots>
        <swiper-item v-for="item in banners" :key="item.id" @click="onBannerClick(item)">
          <image :src="item.imageUrl" mode="aspectFill" class="banner-img" />
        </swiper-item>
      </swiper>
      <view v-else class="hero-tactical-card" @click="goCategory(100)">
        <view class="hero-hud-grid" />
        <view class="hero-header">
          <text class="hero-tag">OPERATIONS / 烽火地带</text>
          <text class="hero-status">● 78位特战干员在线待命</text>
        </view>
        <view class="hero-title">高价值物资全装护航 · 保底安全撤离</view>
        <view class="hero-subtitle">零号大坝 / 长弓溪谷 / 航天基地 · 100%纯手工绿色护航</view>
        <view class="hero-footer">
          <text class="hero-action-btn">预约特战护航 ➔</text>
        </view>
      </view>

      <!-- 平台核心服务保障条 -->
      <view class="guarantee-bar">
        <view class="guarantee-item">
          <text class="g-icon">🛡️</text>
          <text class="g-text">纯手工无外挂</text>
        </view>
        <view class="guarantee-item">
          <text class="g-icon">💎</text>
          <text class="g-text">掉装全额包赔</text>
        </view>
        <view class="guarantee-item">
          <text class="g-icon">⚡</text>
          <text class="g-text">未达保底重打</text>
        </view>
        <view class="guarantee-item">
          <text class="g-icon">🔒</text>
          <text class="g-text">平台资金担保</text>
        </view>
      </view>

      <!-- 公告栏 - 竖向滚动 -->
      <view v-if="notices.length" class="notice-bar" @click="showNoticeList = true">
        <view class="notice-label">
          <text class="notice-badge">特战快讯</text>
        </view>
        <swiper class="notice-swiper" vertical autoplay :interval="3500" :duration="500" circular :disable-touch="true">
          <swiper-item v-for="item in notices" :key="item.id">
            <view class="notice-swiper-item">
              <text class="notice-title">{{ item.title }}</text>
            </view>
          </swiper-item>
        </swiper>
        <text class="notice-more">{{ notices.length }}条 ></text>
      </view>

      <!-- 核心模式金刚区 -->
      <view class="category-grid">
        <view
          v-for="cat in categories"
          :key="cat.id"
          class="category-item"
          @click="goCategory(cat.id)"
        >
          <view class="category-icon-box" :class="getCategoryTheme(cat.name)">
            <text class="cat-symbol">{{ getCategorySymbol(cat.name) }}</text>
          </view>
          <text class="category-name">{{ cat.name }}</text>
        </view>
      </view>

      <!-- 热门战区快捷直达标签 -->
      <view class="quick-map-chips">
        <view class="map-chip" @click="goSearchKeyword('零号大坝')">大坝摸金</view>
        <view class="map-chip" @click="goSearchKeyword('长弓溪谷')">长弓溪谷</view>
        <view class="map-chip" @click="goSearchKeyword('航天基地')">航天基地</view>
        <view class="map-chip" @click="goSearchKeyword('统帅')">统帅冲榜</view>
        <view class="map-chip" @click="goSearchKeyword('连麦')">导师车队</view>
      </view>

      <!-- 带分类的热门推荐：默认全部，可切换护航专区/热门等 -->
      <view class="section">
        <view class="section-header">
          <view class="section-title-wrap">
            <text class="section-title">特战热门委托</text>
            <text class="section-sub">支持指定干员 · 随时退款</text>
          </view>
          <scroll-view scroll-x class="recommend-tabs" :show-scrollbar="false" scroll-with-animation>
            <view
              v-for="tab in recommendTabs"
              :key="tab.id"
              class="recommend-tab"
              :class="{ active: currentRecommendCategoryId === tab.id }"
              @click="switchRecommendCategory(tab.id)"
            >
              {{ tab.name }}
            </view>
          </scroll-view>
        </view>
        <view class="product-grid">
          <ProductCard v-for="p in recommendProducts" :key="p.id" :product="p" />
        </view>
      </view>

      <view class="tab-page-bottom-spacer" />
    </scroll-view>

    <CustomTabBar :current="0" />

    <!-- 悬浮客服按钮 -->
    <view class="cs-float-btn" @click="goCustomerService">
      <image src="/static/icons/客服.svg" mode="aspectFit" class="cs-icon" />
    </view>

    <!-- 公告列表弹窗 -->
    <view class="notice-list-mask" v-if="showNoticeList" @click="showNoticeList = false">
      <view class="notice-list-popup" @click.stop>
        <view class="notice-list-header">
          <text class="notice-list-title">平台安全与业务公告</text>
          <text class="notice-list-close" @click="showNoticeList = false">✕</text>
        </view>
        <scroll-view scroll-y class="notice-list-body">
          <view
            v-for="item in notices"
            :key="item.id"
            class="notice-list-item"
            @click="openNoticeDetail(item); showNoticeList = false"
          >
            <view class="notice-list-dot"></view>
            <view class="notice-list-info">
              <text class="notice-list-name">{{ item.title }}</text>
              <text class="notice-list-time">{{ formatTime(item.createTime) }}</text>
            </view>
            <text class="notice-list-arrow">></text>
          </view>
        </scroll-view>
      </view>
    </view>


    <!-- 公告弹窗 - 支持多公告叠加 -->
    <view class="notice-popup" v-if="showNoticePopup" @click="closeNoticePopup">
      <view class="popup-content" @click.stop>
        <view class="popup-header">
          <text class="popup-title">公告（{{ popupCurrentIndex + 1 }}/{{ popupNotices.length }}）</text>
          <text class="popup-close" @click="closeNoticePopup">✕</text>
        </view>
        <scroll-view scroll-y class="popup-body">
          <text class="popup-notice-title">{{ popupNotices[popupCurrentIndex]?.title }}</text>
          <rich-text v-if="popupNotices[popupCurrentIndex]?.content" :nodes="popupNotices[popupCurrentIndex].content" />
        </scroll-view>
        <view class="popup-footer">
          <view class="popup-nav" v-if="popupNotices.length > 1">
            <view
              class="popup-nav-btn"
              :class="{ disabled: popupCurrentIndex === 0 }"
              @click="popupCurrentIndex > 0 && popupCurrentIndex--"
            >上一条</view>
            <view
              class="popup-nav-btn"
              :class="{ disabled: popupCurrentIndex === popupNotices.length - 1 }"
              @click="popupCurrentIndex < popupNotices.length - 1 && popupCurrentIndex++"
            >下一条</view>
          </view>
          <view class="popup-btn" @click="closeNoticePopup">我知道了</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onPullDownRefresh, onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app'
import ProductCard from '@/components/ProductCard.vue'
import CustomTabBar from '@/components/CustomTabBar.vue'
import { getRecommendProducts, getRecommendCategories } from '@/api/product'
import { getActiveBanners } from '@/api/banner'
import { getActiveNotices } from '@/api/notice'
import { getCategoryTree } from '@/api/category'
import { createCsSession } from '@/api/chat'
import { getRemind } from '@/api/message'
import { useUserStore } from '@/store/user'
import { useChatStore } from '@/store/chat'
import { useSiteStore } from '@/store/site'
const userStore = useUserStore()
const siteStore = useSiteStore()

// 分享给好友
onShareAppMessage(() => ({
  title: siteStore.siteName + ' - ' + siteStore.subtitle,
  path: '/pages/index/index'
}))
// 分享到朋友圈
onShareTimeline(() => ({
  title: siteStore.siteName + ' - ' + siteStore.subtitle
}))
const banners = ref([])
const categories = ref([])
const notices = ref([])
const recommendProducts = ref([])
/** 热门推荐 Tab：全部 + 接口返回的分类（护航专区推荐、热门推荐等） */
const recommendTabs = ref([])
const currentRecommendCategoryId = ref('')
const showNoticePopup = ref(false)
const popupNotices = ref([])
const popupCurrentIndex = ref(0)
const showNoticeList = ref(false)

function formatTime(t) {
  if (!t) return ''
  const d = new Date(t)
  return `${d.getMonth() + 1}-${d.getDate()}`
}

async function loadData() {
  const _t = Date.now()
  try {
    const opts = { loading: false }
    const [bannerRes, noticeRes, catRes, categoriesRes] = await Promise.all([
      getActiveBanners(opts),
      getActiveNotices(opts),
      getCategoryTree(opts),
      getRecommendCategories(opts),
    ])

    // 轮播图
    if (bannerRes.data) {
      banners.value = bannerRes.data.records || bannerRes.data || []
    }
    // 公告
    if (noticeRes.data) {
      const list = noticeRes.data.records || noticeRes.data || []
      notices.value = list
      // 筛选出需要弹窗展示的公告
      const popupList = list.filter(n => n.popupDisplay === 1)
      if (popupList.length > 0) {
        const seenIds = uni.getStorageSync('seenNoticeIds') || []
        const unseenList = popupList.filter(n => !seenIds.includes(String(n.id)))
        if (unseenList.length > 0) {
          popupNotices.value = unseenList
          popupCurrentIndex.value = 0
          showNoticePopup.value = true
        }
      }
    }
    // 分类（树接口返回父级）
    if (catRes.data) {
      categories.value = (catRes.data || []).slice(0, 8)
    }
    // 热门推荐分类 Tab（不含"全部热门"，默认选中第一个）
    if (categoriesRes.data && Array.isArray(categoriesRes.data)) {
      recommendTabs.value = categoriesRes.data.map(c => ({ id: String(c.id), name: c.name }))
      if (recommendTabs.value.length > 0 && !currentRecommendCategoryId.value) {
        currentRecommendCategoryId.value = recommendTabs.value[0].id
      }
    }
    // 推荐商品
    const productParams = currentRecommendCategoryId.value ? { categoryId: currentRecommendCategoryId.value } : {}
    const productRes = await getRecommendProducts(productParams, opts)
    if (productRes.data) {
      recommendProducts.value = productRes.data.records || productRes.data || []
    }
  } catch (e) {
    console.error('load home data error', e)
  }
  console.log(`[HOME] loadData done ${Date.now() - _t}ms`)
}

onShow(() => {
  loadData()
  if (useUserStore().token) {
    getRemind({ loading: false }).then(res => {
      const d = res.data || {}
      useChatStore().setUnreadFromServer(d.messageUnread ?? 0)
      useChatStore().setSystemUnreadFromServer(d.systemUnread ?? 0)
    }).catch(() => {})
  }
})

onPullDownRefresh(async () => {
  await loadData()
  uni.stopPullDownRefresh()
})

function switchRecommendCategory(id) {
  if (currentRecommendCategoryId.value === id) return
  currentRecommendCategoryId.value = id
  const params = id ? { categoryId: id } : {}
  getRecommendProducts(params, { loading: false }).then(res => {
    recommendProducts.value = res.data?.records || res.data || []
  }).catch(() => {})
}

function goSearch() {
  uni.navigateTo({ url: '/pages/product/list?focus=1' })
}

function onBannerClick(item) {
  if (item.linkType === 'product' && item.linkValue) {
    uni.navigateTo({ url: `/pages/product/detail?id=${item.linkValue}` })
  } else if (item.linkType === 'url' && item.linkValue) {
    // 外部链接可通过webview打开
  }
}

function goCategory(id) {
  if (id) uni.setStorageSync('selectedCategoryId', id)
  uni.switchTab({ url: '/pages/category/index' })
}

function openNoticeDetail(item) {
  popupNotices.value = [item]
  popupCurrentIndex.value = 0
  showNoticePopup.value = true
}

function closeNoticePopup() {
  showNoticePopup.value = false
  // 记录已看过的弹窗公告ID
  const seenIds = uni.getStorageSync('seenNoticeIds') || []
  popupNotices.value.forEach(n => {
    if (n.id && !seenIds.includes(String(n.id))) {
      seenIds.push(String(n.id))
    }
  })
  uni.setStorageSync('seenNoticeIds', seenIds)
}

async function goCustomerService() {
  if (!userStore.checkLogin()) return
  try {
    const res = await createCsSession()
    const session = res.data
    uni.navigateTo({ url: '/pages/chat/room?sessionId=' + session.id + '&name=' + encodeURIComponent('在线客服') })
  } catch (e) {
    uni.showToast({ title: e?.msg || '连接客服失败', icon: 'none' })
  }
}

function getCategorySymbol(name) {
  if (!name) return '◈'
  if (name.includes('烽火') || name.includes('摸金')) return '🛡️'
  if (name.includes('战场') || name.includes('排位') || name.includes('冲榜')) return '⚔️'
  if (name.includes('车队') || name.includes('特训') || name.includes('连麦')) return '🎧'
  if (name.includes('特勤') || name.includes('任务') || name.includes('成就')) return '🔑'
  return '◈'
}

function getCategoryTheme(name) {
  if (!name) return 'theme-amber'
  if (name.includes('烽火') || name.includes('摸金')) return 'theme-amber'
  if (name.includes('战场') || name.includes('冲榜')) return 'theme-cyan'
  if (name.includes('车队') || name.includes('特训')) return 'theme-gold'
  if (name.includes('特勤') || name.includes('任务')) return 'theme-purple'
  return 'theme-amber'
}

function goSearchKeyword(kw) {
  uni.navigateTo({ url: `/pages/product/list?keyword=${encodeURIComponent(kw)}` })
}
</script>

<style lang="scss" scoped>
.home-page {
  background: #f8fafc;
  min-height: 100vh;
  position: relative;
  overflow: hidden;
}

/* === 顶部特战品牌识别栏 === */
.header-brand-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 28rpx 8rpx;

  .brand-left {
    display: flex;
    flex-direction: column;

    .brand-sub {
      font-size: 18rpx;
      font-weight: 700;
      color: #b45309;
      letter-spacing: 2rpx;
      font-family: monospace;
    }
    .brand-main {
      font-size: 34rpx;
      font-weight: 800;
      color: #0f172a;
      letter-spacing: 0.5rpx;
    }
  }

  .brand-guarantee-pill {
    display: flex;
    align-items: center;
    background: #fef3c7;
    border: 1rpx solid rgba(245, 158, 11, 0.4);
    padding: 6rpx 16rpx;
    border-radius: 999rpx;

    .pill-dot {
      color: #10b981;
      font-size: 16rpx;
      margin-right: 8rpx;
    }
    .pill-text {
      font-size: 20rpx;
      color: #92400e;
      font-weight: 600;
    }
  }
}

/* === 搜索栏 === */
.search-bar {
  position: relative;
  z-index: 2;
  padding: 12rpx 24rpx 16rpx;
  background: transparent;

  .search-inner {
    height: 80rpx;
    background: #ffffff;
    border: 1.5rpx solid #e2e8f0;
    border-radius: 999rpx;
    display: flex;
    align-items: center;
    padding: 0 28rpx;
    box-shadow: 0 4rpx 16rpx rgba(15, 23, 42, 0.05);

    .search-icon {
      font-size: 30rpx;
      color: #94a3b8;
      margin-right: 14rpx;
    }
    .search-placeholder {
      font-size: 26rpx;
      color: #64748b;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
  }
}

/* === 战术英雄展板 === */
.hero-tactical-card {
  position: relative;
  margin: 0 24rpx;
  padding: 30rpx 28rpx;
  border-radius: 20rpx;
  background: linear-gradient(145deg, #0f172a 0%, #1e293b 60%, #0b1120 100%);
  border: 1rpx solid rgba(245, 158, 11, 0.3);
  box-shadow: 0 10rpx 30rpx rgba(15, 23, 42, 0.18);
  overflow: hidden;

  .hero-hud-grid {
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    background-image: linear-gradient(rgba(245, 158, 11, 0.04) 1px, transparent 1px),
                      linear-gradient(90deg, rgba(245, 158, 11, 0.04) 1px, transparent 1px);
    background-size: 24rpx 24rpx;
    pointer-events: none;
  }

  .hero-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 14rpx;
    position: relative;
    z-index: 1;

    .hero-tag {
      font-size: 20rpx;
      color: #f59e0b;
      font-weight: 700;
      letter-spacing: 1.5rpx;
      font-family: monospace;
    }
    .hero-status {
      font-size: 20rpx;
      color: #10b981;
      font-weight: 500;
    }
  }

  .hero-title {
    font-size: 32rpx;
    font-weight: 800;
    color: #ffffff;
    line-height: 1.35;
    margin-bottom: 10rpx;
    position: relative;
    z-index: 1;
  }

  .hero-subtitle {
    font-size: 22rpx;
    color: #94a3b8;
    line-height: 1.4;
    position: relative;
    z-index: 1;
    margin-bottom: 20rpx;
  }

  .hero-footer {
    display: flex;
    justify-content: flex-end;
    position: relative;
    z-index: 1;

    .hero-action-btn {
      font-size: 22rpx;
      font-weight: 700;
      color: #0f172a;
      background: #f59e0b;
      padding: 8rpx 22rpx;
      border-radius: 999rpx;
      box-shadow: 0 4rpx 14rpx rgba(245, 158, 11, 0.35);
    }
  }
}

/* === 核心保障条 === */
.guarantee-bar {
  display: flex;
  align-items: center;
  justify-content: space-around;
  margin: 18rpx 24rpx 0;
  padding: 16rpx 12rpx;
  background: #ffffff;
  border-radius: 14rpx;
  border: 1rpx solid #e2e8f0;
  box-shadow: 0 2rpx 10rpx rgba(15, 23, 42, 0.04);

  .guarantee-item {
    display: flex;
    align-items: center;
    gap: 6rpx;

    .g-icon {
      font-size: 24rpx;
    }
    .g-text {
      font-size: 20rpx;
      font-weight: 600;
      color: #334155;
    }
  }
}

/* === 热门战区快捷选项卡 === */
.quick-map-chips {
  display: flex;
  align-items: center;
  gap: 14rpx;
  padding: 0 24rpx;
  margin-top: 18rpx;
  overflow-x: auto;
  white-space: nowrap;

  .map-chip {
    font-size: 22rpx;
    font-weight: 600;
    color: #475569;
    background: #ffffff;
    border: 1rpx solid #cbd5e1;
    padding: 8rpx 20rpx;
    border-radius: 999rpx;
    flex-shrink: 0;

    &:active {
      background: #fef3c7;
      color: #b45309;
      border-color: #f59e0b;
    }
  }
}

.banner {
  height: 380rpx;
  margin: 0 24rpx;
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);

  .banner-img { width: 100%; height: 100%; }
}

.notice-bar {
  display: flex;
  align-items: center;
  margin: 18rpx 24rpx;
  padding: 0 20rpx;
  height: 72rpx;
  background: #ffffff;
  border-radius: 12rpx;
  overflow: hidden;
  border: 1rpx solid #e2e8f0;
  box-shadow: 0 2rpx 12rpx rgba(15, 23, 42, 0.04);
}
.notice-label {
  display: flex;
  align-items: center;
  flex-shrink: 0;
  margin-right: 14rpx;
  padding-right: 14rpx;
  border-right: 1rpx solid #e2e8f0;

  .notice-badge {
    font-size: 20rpx;
    font-weight: 700;
    color: #b45309;
    background: #fef3c7;
    padding: 4rpx 10rpx;
    border-radius: 6rpx;
  }
}
/* === 核心模式金刚区 === */
.category-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20rpx 14rpx;
  padding: 24rpx 20rpx;
  background: #ffffff;
  margin: 18rpx 24rpx 0;
  border-radius: 16rpx;
  border: 1rpx solid #e2e8f0;
  box-shadow: 0 4rpx 16rpx rgba(15, 23, 42, 0.04);
}
.category-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
  &:active { opacity: 0.85; transform: scale(0.98); }
}
.category-icon-box {
  width: 92rpx;
  height: 92rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8fafc;
  border: 1rpx solid #e2e8f0;
  box-shadow: 0 2rpx 8rpx rgba(15, 23, 42, 0.05);

  &.theme-amber {
    background: linear-gradient(135deg, #fef3c7, #fde68a);
    border-color: rgba(245, 158, 11, 0.4);
  }
  &.theme-cyan {
    background: linear-gradient(135deg, #e0f2fe, #bae6fd);
    border-color: rgba(6, 182, 212, 0.4);
  }
  &.theme-gold {
    background: linear-gradient(135deg, #fef9c3, #fef08a);
    border-color: rgba(234, 179, 8, 0.4);
  }
  &.theme-purple {
    background: linear-gradient(135deg, #f3e8ff, #e9d5ff);
    border-color: rgba(168, 85, 247, 0.4);
  }

  .cat-symbol {
    font-size: 38rpx;
    line-height: 1;
  }
}
.category-name {
  font-size: 22rpx;
  font-weight: 600;
  color: #1e293b;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
}

/* === 推荐委托区域 === */
.section {
  padding: 24rpx;
}
.section-header {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  margin-bottom: 20rpx;

  .section-title-wrap {
    display: flex;
    align-items: baseline;
    gap: 14rpx;

    .section-title {
      font-size: 32rpx;
      font-weight: 800;
      color: #0f172a;
      letter-spacing: 0.5rpx;
    }
    .section-sub {
      font-size: 20rpx;
      color: #64748b;
    }
  }
}
.recommend-tabs {
  width: 100%;
  white-space: nowrap;
  height: 60rpx;
}
.recommend-tab {
  display: inline-block;
  padding: 10rpx 24rpx;
  font-size: 22rpx;
  font-weight: 600;
  color: #64748b;
  background: #ffffff;
  border: 1rpx solid #e2e8f0;
  border-radius: 999rpx;
  margin-right: 14rpx;

  &.active {
    color: #0f172a;
    font-weight: 700;
    background: linear-gradient(135deg, #fef3c7, #fde68a);
    border-color: #f59e0b;
    box-shadow: 0 2rpx 10rpx rgba(245, 158, 11, 0.25);
  }
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20rpx;
  overflow: hidden;
}


.notice-popup {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;

  .popup-content {
    width: 600rpx;
    max-height: 70vh;
    background: #ffffff;
    border-radius: 24rpx;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    box-shadow: 0 16rpx 48rpx rgba(0, 0, 0, 0.15);
  }

  .popup-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 28rpx 32rpx;
    border-bottom: 1rpx solid #e2e8f0;

    .popup-title { font-size: 32rpx; font-weight: bold; color: #4f46e5; }
    .popup-close { font-size: 36rpx; color: #94a3b8; padding: 0 8rpx; }
  }

  .popup-body {
    padding: 32rpx;
    max-height: 50vh;

    .popup-notice-title { font-size: 30rpx; font-weight: bold; color: #0f172a; display: block; margin-bottom: 20rpx; }
  }

  .popup-footer {
    padding: 24rpx 32rpx;
    border-top: 1rpx solid #e2e8f0;

    .popup-nav {
      display: flex;
      justify-content: center;
      gap: 32rpx;
      margin-bottom: 20rpx;

      .popup-nav-btn {
        font-size: 26rpx;
        color: #4f46e5;
        padding: 8rpx 24rpx;
        border: 1rpx solid rgba(99, 102, 241, 0.15);
        border-radius: 999rpx;

        &.disabled {
          color: #cbd5e1;
          border-color: #e2e8f0;
        }
      }
    }

    .popup-btn {
      height: 76rpx;
      line-height: 76rpx;
      text-align: center;
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
      color: #ffffff;
      font-weight: bold;
      border-radius: 999rpx;
      font-size: 28rpx;
    }
  }
}
.cs-float-btn {
  position: fixed;
  right: 24rpx;
  bottom: 240rpx;
  width: 100rpx;
  height: 100rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(255, 107, 43, 0.4);
  z-index: 100;

  .cs-icon {
    width: 52rpx;
    height: 52rpx;
    filter: brightness(0) saturate(100%) invert(100%);
  }
}
</style>
