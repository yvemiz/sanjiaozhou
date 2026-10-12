<template>
  <view class="apply-page">
    <view class="hero-banner">
      <view class="banner-badge">DELTA FORCE OPERATOR</view>
      <text class="banner-title">特战干员认证入驻</text>
      <text class="banner-sub">加入三角洲精英护航车队 · 平台担保结单 · 自由接单收益丰厚</text>
    </view>

    <view class="section-title">
      <text class="bar"></text>
      <text class="title-text">基本信息</text>
    </view>
    <view class="form-item">
      <text class="label">真实姓名 <text class="required">*</text></text>
      <input v-model="form.realName" placeholder="用于平台实名与结算验证" />
    </view>
    <view class="form-item">
      <text class="label">联系电话 / 微信 <text class="required">*</text></text>
      <input v-model="form.phone" type="number" placeholder="请保持接单联络畅通" />
    </view>

    <view class="section-title">
      <text class="bar"></text>
      <text class="title-text">战术干员履历</text>
    </view>
    <view class="form-item">
      <text class="label">三角洲角色名与数字ID <text class="required">*</text></text>
      <input v-model="form.gameLevel" placeholder="例：GTI_红狼 / 90812344" />
    </view>
    <view class="form-item">
      <text class="label">当前段位 / 烽火地带胜率</text>
      <input v-model="form.serviceTypes" placeholder="例：烽火统帅三星 / 撤离率68% / 战力8500" />
    </view>
    <view class="form-item">
      <text class="label">擅长干员 / 战术定位</text>
      <input v-model="form.skillTags" placeholder="例：红狼/威龙突破手、骇爪报点、航天基地带砖" />
    </view>

    <view class="section-title">
      <text class="bar"></text>
      <text class="title-text">战绩与战备资产凭证</text>
    </view>
    <view class="form-item uploader-item">
      <text class="label-sub">请上传游戏战绩总览、仓库价值或主玩干员界面截图（最多4张）</text>
      <ImageUploader v-model="proofImages" :max="4" />
    </view>

    <view v-if="siteStore.depositRequired" class="deposit-tip">
      <text class="tip-icon">ⓘ</text>
      <text>特战干员履约入驻需缴纳安全押金，防跑单/违规扣款，退出可申请全额退回</text>
    </view>

    <view class="btn" :class="{ disabled: submitting }" @click="submit">
      {{ submitting ? '审核资质提交中...' : (siteStore.depositRequired ? '支付押金并申请入驻' : '提交干员认证申请') }}
    </view>
  </view>
</template>

<script setup>
import { reactive, ref } from 'vue'
import ImageUploader from '@/components/ImageUploader.vue'
import { applyPlayer } from '@/api/player'
import { createPlayerDeposit } from '@/api/pay'
import { useSiteStore } from '@/store/site'
import { isMpWeixin } from '@/utils/platform'

const siteStore = useSiteStore()
const canUseWechatPay = isMpWeixin()
const form = reactive({ realName: '', phone: '', gameLevel: '', serviceTypes: '', skillTags: '' })
const proofImages = ref([])
const submitting = ref(false)

async function submit() {
  if (!form.realName || !form.phone || !form.gameLevel) {
    return uni.showToast({ title: '请填写姓名、电话及游戏ID', icon: 'none' })
  }
  if (submitting.value) return
  submitting.value = true
  try {
    if (siteStore.depositRequired) {
      await submitWithDeposit()
    } else {
      await applyPlayer({
        ...form,
        proofImages: proofImages.value.join(',')
      })
      uni.showToast({ title: '申请已提交，等待审核' })
      setTimeout(() => uni.navigateBack(), 1500)
    }
  } catch (e) {
    if (e && e.errMsg && !e.errMsg.includes('cancel')) {
      uni.showToast({ title: e.msg || '操作失败', icon: 'none' })
    }
  } finally {
    submitting.value = false
  }
}

async function submitWithDeposit() {
  if (!canUseWechatPay) {
    uni.showToast({ title: 'H5暂未接入在线支付，请在小程序端操作', icon: 'none' })
    throw new Error('H5 payment is not supported')
  }
  const res = await createPlayerDeposit()
  const { paymentNo, timeStamp, nonceStr, package: pkg, signType, paySign } = res.data
  await new Promise((resolve, reject) => {
    uni.requestPayment({
      provider: 'wxpay',
      timeStamp,
      nonceStr,
      package: pkg,
      signType: signType || 'RSA',
      paySign,
      success: () => resolve(),
      fail: (e) => reject(e)
    })
  })
  const doApply = () => applyPlayer({
    ...form,
    proofImages: proofImages.value.join(','),
    depositPaymentNo: paymentNo
  })
  try {
    await doApply()
  } catch (e) {
    if (e?.msg?.includes('未到账')) {
      uni.showToast({ title: '支付到账中，请稍候...', icon: 'none' })
      await new Promise(r => setTimeout(r, 2500))
      await doApply()
    } else {
      throw e
    }
  }
  uni.showToast({ title: '申请已提交，等待审核' })
  setTimeout(() => uni.navigateBack(), 1500)
}
</script>

<style lang="scss" scoped>
.apply-page {
  padding: 24rpx 24rpx 80rpx;
  background: #0b1120;
  min-height: 100vh;
  color: #f1f5f9;
}

.hero-banner {
  background: linear-gradient(135deg, #1e293b, #0f172a);
  border: 1rpx solid #334155;
  border-radius: 16rpx;
  padding: 30rpx 24rpx;
  margin-bottom: 30rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.4);

  .banner-badge {
    display: inline-block;
    font-size: 18rpx;
    font-weight: 800;
    letter-spacing: 2rpx;
    color: #f59e0b;
    background: rgba(245, 158, 11, 0.15);
    border: 1rpx solid rgba(245, 158, 11, 0.4);
    padding: 2rpx 12rpx;
    border-radius: 6rpx;
    margin-bottom: 12rpx;
  }

  .banner-title {
    font-size: 36rpx;
    font-weight: 800;
    color: #ffffff;
    display: block;
    letter-spacing: 1rpx;
  }

  .banner-sub {
    font-size: 22rpx;
    color: #94a3b8;
    margin-top: 10rpx;
    display: block;
    line-height: 1.4;
  }
}

.section-title {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 28rpx 0 16rpx;

  .bar {
    width: 6rpx;
    height: 24rpx;
    background: #f59e0b;
    border-radius: 3rpx;
  }

  .title-text {
    font-size: 26rpx;
    font-weight: 700;
    color: #cbd5e1;
    letter-spacing: 1rpx;
  }
}

.form-item {
  background: #1e293b;
  border: 1rpx solid #334155;
  padding: 22rpx 24rpx;
  border-radius: 14rpx;
  margin-bottom: 18rpx;

  .label {
    font-size: 25rpx;
    color: #94a3b8;
    margin-bottom: 12rpx;
    display: block;
    font-weight: 600;

    .required {
      color: #ef4444;
      margin-left: 4rpx;
    }
  }

  .label-sub {
    font-size: 22rpx;
    color: #64748b;
    margin-bottom: 16rpx;
    display: block;
  }

  input {
    height: 72rpx;
    background: #0f172a;
    border: 1rpx solid #334155;
    border-radius: 10rpx;
    padding: 0 20rpx;
    font-size: 27rpx;
    color: #f8fafc;
  }
}

.deposit-tip {
  font-size: 23rpx;
  color: #fbbf24;
  background: rgba(245, 158, 11, 0.1);
  border: 1rpx solid rgba(245, 158, 11, 0.25);
  border-radius: 10rpx;
  padding: 16rpx 20rpx;
  margin-top: 20rpx;
  display: flex;
  align-items: flex-start;
  gap: 10rpx;
  line-height: 1.4;

  .tip-icon {
    font-size: 26rpx;
    font-weight: bold;
  }
}

.btn {
  height: 92rpx;
  line-height: 92rpx;
  text-align: center;
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: #0f172a;
  font-weight: 800;
  font-size: 32rpx;
  letter-spacing: 2rpx;
  border-radius: 14rpx;
  margin-top: 40rpx;
  box-shadow: 0 8rpx 20rpx rgba(217, 119, 6, 0.35);

  &.disabled {
    opacity: 0.6;
  }
}
</style>
