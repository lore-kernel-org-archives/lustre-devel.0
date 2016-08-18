From: Patrick Farrell <paf@cray.com>
Date: Thu, 18 Aug 2016 20:00:46 +0000
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
Message-ID: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Good afternoon,


I'm trying to build and install updated Lustre master on CentOS 6 for the first time in a month or two, and I'm having trouble.


I use the build procedure documented here:

https://wiki.hpdd.intel.com/pages/viewpage.action?pageId=8126821


I've got some new kmod-* RPMs, and I need to install those to install Lustre, which is fine, except I get a huge string of messages like this when I try:

error: Failed dependencies:
        ksym(__init_waitqueue_head) = 0xffc7c184 is needed by kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
        ksym(__mutex_init) = 0x4bf79039 is needed by kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64

I've rebuilt and reinstalled my kernel with this latest version of Lustre.  Error messages remain the same, and I can't install.


Any thoughts or advice?


- Patrick
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160818/9eda7c04/attachment.htm>
