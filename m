From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 21 Oct 2016 09:20:14 +0200
Subject: [lustre-devel] [PATCH] Staging: lustre: lov: check return value
	of lov_sub_get()
In-Reply-To: <20161020233352.14879-1-jinshan.xiong@intel.com>
References: <20161020233352.14879-1-jinshan.xiong@intel.com>
Message-ID: <20161021072014.GA22615@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jinshan Xiong <jinshan.xiong@intel.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Oct 21, 2016 at 07:33:52AM +0800, Jinshan Xiong wrote:
> Check return value of lov_sub_get() in lov_io_read_ahead().
> 
> Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>

No reported-by: tag?
