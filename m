From: Scott Atchley <atchley@myri.com>
Date: Tue, 24 Feb 2009 13:32:25 -0500
Subject: [Lustre-devel] Credits, peer credits and concurrent sends
Message-ID: <FCCFA143-03D6-45C3-93EC-61F106BF8193@myri.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

I am updating MXLND. I am looking at O2IBLND as a reference and I am  
wondering what is the difference between the above module parameters?

The o2iblnd_modparams.c file has:

static int credits = 64;
CFS_MODULE_PARM(credits, "i", int, 0444,
                 "# concurrent sends");

static int peer_credits = 8;
CFS_MODULE_PARM(peer_credits, "i", int, 0444,
                 "# concurrent sends to 1 peer");

#if IBLND_MAP_ON_DEMAND
static int concurrent_sends = IBLND_RX_MSGS;
#else
static int concurrent_sends = IBLND_MSG_QUEUE_SIZE;
#endif
CFS_MODULE_PARM(concurrent_sends, "i", int, 0444,
                 "send work-queue sizing");

where IBLND_MSG_QUEUE_SIZE is 8.

Can anyone elaborate on differences and relationships (e.g. what does  
it mean if concurrent_sends is greater than peer_credits or is that  
not allowed)?

Thanks,

Scott


--
Scott Atchley
Myricom Inc.
http://www.myri.com
