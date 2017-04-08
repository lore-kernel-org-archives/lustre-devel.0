From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 8 Apr 2017 12:45:22 +0200
Subject: [lustre-devel] [PATCH] drivers/staging: lustre: Avoiding
 multiple line dereference
In-Reply-To: <1491298170-29104-1-git-send-email-pushkar.iit@gmail.com>
References: <1491298170-29104-1-git-send-email-pushkar.iit@gmail.com>
Message-ID: <20170408104522.GA5245@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pushkar Jambhlekar <pushkar.iit@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, "John L. Hammond" <john.hammond@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Siyao <lai.siyao@intel.com>, James Nunez <james.a.nunez@intel.com>, Andrew Perepechko <andrew.perepechko@seagate.com>, wang di <di.wang@intel.com>, Bob Glossman <bob.glossman@intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Bobi Jam <bobijam@hotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Henri Doreau <henri.doreau@cea.fr>, Prakash Surya <surya1@llnl.gov>, Emoly Liu <emoly.liu@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Johann Lombardi <johann.lombardi@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Tue, Apr 04, 2017 at 02:59:30PM +0530, Pushkar Jambhlekar wrote:
> Making references in single line

Why?  Now the line is too long :(

Will this be a constant stream of patches, one making this change, and
the other the original?

sorry,

greg k-h
