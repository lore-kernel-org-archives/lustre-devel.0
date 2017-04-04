From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 4 Apr 2017 20:29:34 +0200
Subject: [lustre-devel] [PATCH] drivers/staging/lustre: Replacing
 'unsigned' with 'unsigned int'
In-Reply-To: <1491299043-29224-1-git-send-email-pushkar.iit@gmail.com>
References: <1491299043-29224-1-git-send-email-pushkar.iit@gmail.com>
Message-ID: <20170404182934.GA3697@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, "John L. Hammond" <john.hammond@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Siyao <lai.siyao@intel.com>, James Nunez <james.a.nunez@intel.com>, Andrew Perepechko <andrew.perepechko@seagate.com>, wang di <di.wang@intel.com>, Bob Glossman <bob.glossman@intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Bobi Jam <bobijam@hotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Henri Doreau <henri.doreau@cea.fr>, Prakash Surya <surya1@llnl.gov>, Emoly Liu <emoly.liu@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Johann Lombardi <johann.lombardi@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Tue, Apr 04, 2017 at 03:14:03PM +0530, Pushkar Jambhlekar wrote:
> Replacing 'unsigned' with 'unsigned int'

Why?  You need to explain why you do something, not just say what you
did (that should be obvious if you read the patch...)

thanks,

greg k-h
