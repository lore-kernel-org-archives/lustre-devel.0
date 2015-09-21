From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 21 Sep 2015 15:33:32 +0200
Subject: [lustre-devel] [PATCH 00/38] Fixes related to incorrect usage of
	unsigned types
Message-ID: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

This is set of independent patches. The only connection between
them is that they try to address problems spotted by proposed
coccinelle semantic patch unsigned_lesser_than_zero.cocci[1].

Semantic patch finds comparisons of types:
    unsigned < 0
    unsigned >= 0
The former is always false, the latter is always true.
Such comparisons are useless, so theoretically they could be
safely removed, but their presence quite often indicates bugs.

This patchset contains mainly real bug fixes(patches 01-25),
usually type fixes.

Patches 26-37 removes unnecessary checks. Semantic patch found
much more such places (more than 80), but since every case needs
some analysis I have decided to leave them for antoher patchset.

The last patch should be probably replaced with something better,
I guess it should be treated rather as bug report.

The patches are based on linux-next (20150918).

Patches were only compile tested, so please look at them carefully.

I have sent all patches to linux-kernel mailing list. Individual
patches + cover letter went also to apropriate addresses,
according to get_maintainers.pl script.

One more thing. To fullfill different maintaner/subsystem requirements
I have decided to prefix patch subjects with prefixes present in
last 10 commits for affected files. I am not sure if this is the
best solution, if there are any better solutions please let me know :)

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Regards
Andrzej


Andrzej Hajda (38):
  arm-cci: fix handling cpumask_any_but return value
  bus: arm-ccn: fix handling cpumask_any_but return value
  drm/i915: fix handling gen8_emit_flush_coherentl3_wa result
  IB/ehca: fix handling idr_alloc result
  staging: lustre: fix handling lustre_posix_acl_xattr_filter result
  tty: serial: lpc32xx_hs: fix handling platform_get_irq result
  usb: host: ehci-msm: fix handling platform_get_irq result
  openvswitch: fix handling result of ipv6_skip_exthdr
  selftests/timers: fix write return value handlng
  hwrng: fix handling platform_get_irq
  HSI: omap_ssi: fix handling ida_simple_get result
  HSI: omap_ssi_port: fix handling of_get_named_gpio result
  ARM: shmobile: apmu: correct type of CPU id
  clk: vt8500: fix sign of possible PLL values
  drm/layerscape: fix handling fsl_dcu_drm_plane_index result
  gpu: ipu-v3: fix div_ratio type
  isdn: hisax: fix frame calculation
  net/ibm/emac: fix type of phy_mode
  net: stmmac: fix type of entry variable
  net: brcm80211: fix range check
  mwifiex: fix comparison expression
  orinoco: fix checking for default value
  rndis_wlan: fix checking for default value
  rtc: opal: fix type of token
  staging: media: davinci_vpfe: fix ipipe_mode type
  staging: lustre: remove invalid check
  usbnet: remove invalid check
  video/omap: remove invalid check
  Input: touchscreen: atmel: remove invalid check
  leds: flash: remove invalid check
  leds: tca6507: remove invalid check
  fs/cachefiles: remove invalid checks
  mm/memblock.c: remove invalid check
  perf: remove invalid check
  ptrace: remove invalid check
  MIPS: remove invalid check
  zlib_deflate/deftree: change always true condition to 1
  drm/radeon: simplify boot level calculation

 arch/arm/mach-shmobile/platsmp-apmu.c               |  2 +-
 arch/mips/mm/sc-mips.c                              |  4 ++--
 arch/sh/kernel/ptrace_32.c                          |  3 +--
 arch/sh/kernel/ptrace_64.c                          |  4 ++--
 drivers/bus/arm-cci.c                               |  2 +-
 drivers/bus/arm-ccn.c                               |  2 +-
 drivers/char/hw_random/xgene-rng.c                  |  7 ++++---
 drivers/clk/clk-vt8500.c                            |  6 +++---
 drivers/gpu/drm/amd/amdgpu/kv_dpm.c                 | 11 +----------
 drivers/gpu/drm/fsl-dcu/fsl_dcu_drm_plane.c         |  3 ++-
 drivers/gpu/drm/i915/intel_lrc.c                    |  7 ++++---
 drivers/gpu/drm/radeon/kv_dpm.c                     | 11 +----------
 drivers/gpu/ipu-v3/ipu-csi.c                        |  2 +-
 drivers/hsi/controllers/omap_ssi.c                  |  7 +++----
 drivers/hsi/controllers/omap_ssi_port.c             |  8 ++++----
 drivers/input/touchscreen/atmel_mxt_ts.c            |  2 +-
 drivers/isdn/hisax/hfc4s8s_l1.c                     | 10 +++++-----
 drivers/leds/led-class-flash.c                      |  2 +-
 drivers/leds/leds-tca6507.c                         |  2 +-
 drivers/net/ethernet/ibm/emac/core.h                |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c   |  2 +-
 drivers/net/usb/lan78xx.c                           |  5 -----
 drivers/net/usb/smsc75xx.c                          |  5 -----
 drivers/net/usb/smsc95xx.c                          |  5 -----
 drivers/net/wireless/brcm80211/brcmsmac/main.c      |  2 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c        |  4 ++--
 drivers/net/wireless/orinoco/cfg.c                  |  6 +++---
 drivers/net/wireless/rndis_wlan.c                   |  2 +-
 drivers/rtc/rtc-opal.c                              |  4 ++--
 drivers/staging/lustre/lustre/llite/xattr.c         |  7 ++++---
 drivers/staging/lustre/lustre/osc/lproc_osc.c       |  3 ---
 drivers/staging/media/davinci_vpfe/dm365_ipipe_hw.c |  2 +-
 drivers/staging/rdma/ehca/ehca_cq.c                 | 13 +++++++------
 drivers/tty/serial/lpc32xx_hs.c                     |  7 ++++---
 drivers/usb/host/ehci-msm.c                         |  6 +++---
 drivers/video/fbdev/omap/omapfb_main.c              |  5 -----
 fs/cachefiles/bind.c                                |  9 +++------
 fs/cachefiles/daemon.c                              |  6 +++---
 lib/zlib_deflate/deftree.c                          |  2 +-
 mm/memblock.c                                       |  2 +-
 net/openvswitch/conntrack.c                         |  2 +-
 tools/testing/selftests/timers/clocksource-switch.c |  2 +-
 42 files changed, 79 insertions(+), 119 deletions(-)

-- 
1.9.1
