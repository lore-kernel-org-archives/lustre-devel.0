From: Zhuravlev, Alexey <alexey.zhuravlev@intel.com>
Date: Mon, 17 Dec 2012 07:04:36 +0000
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <AE8E737235CD0640B291384BFC2D8A354A3A7348@MX10A.corp.emc.com>
References: <2BD6B3FE-788D-4B27-8759-FFCB2EC612D6@intel.com>
	<201212170544.qBH5iOuM019618@hedwig.cmf.nrl.navy.mil>
	<AE8E737235CD0640B291384BFC2D8A354A3A7348@MX10A.corp.emc.com>
Message-ID: <1C588F06-FEFD-4F95-9713-AADA786EAE24@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Dec 17, 2012, at 10:52 AM, "Liu, Xuezhao" <Xuezhao.Liu@emc.com> wrote:

> Hi,
> 
> Current the libcfs cleanup is mainly done by replacing kinds of libcfs calls with direct kernel primitives, we can implement the portable layer on other OS with the same name as Linux.
> I think the real concern is that on other OS there is possible some kernel primitives have the same name a Linux kernel but with different behavior/parameters, that will cause either compiling broken or running crashing etc.
> I don't have the full list of the above intersecting case, but it should be very rare right? We can build a separate patch( which should be small) for those intersecting cases for other OS, and I guess that patch need to be maintained separately.

originally libcfs_ prefix was introduce to cope with name collisions in Solaris. I'm not sure how this can be solved with a separate small patch.

to me the both goals look hard to achieve, so I'm fine with any solution ;)

thanks, Alex


--------------------------------------------------------------------
Closed Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park, 
17 Krylatskaya Str., Bldg 4, Moscow 121614, 
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
