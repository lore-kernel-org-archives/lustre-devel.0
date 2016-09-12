From: Jes Sorensen <Jes.Sorensen@redhat.com>
Date: Mon, 12 Sep 2016 15:29:38 -0400
Subject: [lustre-devel] [PATCH] staging: squash lines for simple wrapper
	functions
In-Reply-To: <1473706668-24216-1-git-send-email-yamada.masahiro@socionext.com>
	(Masahiro Yamada's message of "Tue, 13 Sep 2016 03:57:48 +0900")
References: <1473706668-24216-1-git-send-email-yamada.masahiro@socionext.com>
Message-ID: <wrfjwpigex25.fsf@redhat.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-fbdev@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, Sumit Semwal <sumit.semwal@linaro.org>, linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>, Teddy Wang <teddy.wang@siliconmotion.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Laura Abbott <labbott@redhat.com>, Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org

Masahiro Yamada <yamada.masahiro@socionext.com> writes:
> Remove unneeded variables and assignments.
>
> While we are here, clean up the following as well:
>   - refactor rtl8723a_get_bcn_valid() a bit
>   - remove unneeded casts in sii164Get{Vendor,Device}ID()
>
> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> ---
>
>  drivers/staging/android/ion/ion.c                        |  6 +-----
>  .../staging/lustre/lustre/obdclass/linux/linux-module.c  |  5 +----
>  drivers/staging/lustre/lustre/ptlrpc/client.c            |  5 +----
>  drivers/staging/lustre/lustre/ptlrpc/events.c            |  5 +----
>  drivers/staging/rtl8723au/core/rtw_wlan_util.c           |  7 +------
>  drivers/staging/rtl8723au/hal/hal_com.c                  |  6 +-----
>  drivers/staging/sm750fb/ddk750_sii164.c                  | 16 ++++------------
>  7 files changed, 10 insertions(+), 40 deletions(-)

1) Do not submit one giant patch modifying multiple drivers in one go
2) drivers/staging/rtl8723au is gone - had you followed 1), you wouldn't
   necessarily have had to respin this patch.
3) Consider if your changes, even if technically correct, actually
   improve the code (see below)

Jes

> diff --git a/drivers/staging/rtl8723au/core/rtw_wlan_util.c b/drivers/staging/rtl8723au/core/rtw_wlan_util.c
> index 694cf17..7ab47f0 100644
> --- a/drivers/staging/rtl8723au/core/rtw_wlan_util.c
> +++ b/drivers/staging/rtl8723au/core/rtw_wlan_util.c
> @@ -1202,12 +1202,7 @@ unsigned int update_supported_rate23a(unsigned char *ptn, unsigned int ptn_sz)
>  
>  unsigned int update_MSC_rate23a(struct ieee80211_ht_cap *pHT_caps)
>  {
> -	unsigned int mask;
> -
> -	mask = pHT_caps->mcs.rx_mask[0] << 12 |
> -		pHT_caps->mcs.rx_mask[1] << 20;
> -
> -	return mask;
> +	return pHT_caps->mcs.rx_mask[0] << 12 | pHT_caps->mcs.rx_mask[1] << 20;
>  }

The use of the mask variable didn't cause any harm, and it was certainly
a lot nicer to read the way it was.

>  int support_short_GI23a(struct rtw_adapter *padapter,
> diff --git a/drivers/staging/rtl8723au/hal/hal_com.c b/drivers/staging/rtl8723au/hal/hal_com.c
> index 9d7b11b..dfbeebe 100644
> --- a/drivers/staging/rtl8723au/hal/hal_com.c
> +++ b/drivers/staging/rtl8723au/hal/hal_com.c
> @@ -708,11 +708,7 @@ void rtl8723a_bcn_valid(struct rtw_adapter *padapter)
>  
>  bool rtl8723a_get_bcn_valid(struct rtw_adapter *padapter)
>  {
> -	bool retval;
> -
> -	retval = (rtl8723au_read8(padapter, REG_TDECTRL + 2) & BIT(0)) ? true : false;
> -
> -	return retval;
> +	return !!(rtl8723au_read8(padapter, REG_TDECTRL + 2) & BIT(0));
>  }

One word: Yuck!

Talk about obfuscating the code for the sake of obfuscation!

>  void rtl8723a_set_beacon_interval(struct rtw_adapter *padapter, u16 interval)
> diff --git a/drivers/staging/sm750fb/ddk750_sii164.c b/drivers/staging/sm750fb/ddk750_sii164.c
> index 67f36e7..28818e1 100644
> --- a/drivers/staging/sm750fb/ddk750_sii164.c
> +++ b/drivers/staging/sm750fb/ddk750_sii164.c
> @@ -36,12 +36,8 @@ static char *gDviCtrlChipName = "Silicon Image SiI 164";
>   */
>  unsigned short sii164GetVendorID(void)
>  {
> -	unsigned short vendorID;
> -
> -	vendorID = ((unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_HIGH) << 8) |
> -		    (unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_LOW);
> -
> -	return vendorID;
> +	return (i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_HIGH) << 8) |
> +		i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_LOW);
>  }
>  
>  /*
> @@ -53,12 +49,8 @@ unsigned short sii164GetVendorID(void)
>   */
>  unsigned short sii164GetDeviceID(void)
>  {
> -	unsigned short deviceID;
> -
> -	deviceID = ((unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_HIGH) << 8) |
> -		    (unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_LOW);
> -
> -	return deviceID;
> +	return (i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_HIGH) << 8) |
> +		i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_LOW);
>  }

Getting rid of the casts would be nice, merging them into a giant
multi-line return line certainly isn't an improvement in my book. That
said, I will leave that to the maintainer of that driver to decide what
is preferred.

Jes
