From: David Binderman <linuxdev.baldrick@gmail.com>
Date: Mon, 23 May 2016 12:17:49 +0100
Subject: [lustre-devel]
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c:235:
 pointless test ?
Message-ID: <CAMzoamaHfSYqLJVcPJmF5ff=t1sxkROUbNz14V2Aenhmk9ZZWA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello there,

drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c:235:34:
warning: comparison of unsigned expression < 0 is always false
[-Wtype-limits]

Source code is

    if (tunables->lnd_map_on_demand < 0 ||


Regards

David Binderman
