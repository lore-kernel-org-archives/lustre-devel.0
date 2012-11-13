From: Ned Bass <bass6@llnl.gov>
Date: Tue, 13 Nov 2012 10:33:02 -0800
Subject: [Lustre-devel] [wc-discuss] Seeking contributors for Lustre
	User Manual
In-Reply-To: <CCC2E817.24EA%andreas.dilger@intel.com>
References: <F4644F70-E8BA-437F-87B1-9A57FADF8254@intel.com>
	<CCC2E817.24EA%andreas.dilger@intel.com>
Message-ID: <20121113183302.GM31700@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Nov 10, 2012 at 12:09:09AM +0000, Dilger, Andreas wrote:
> The manual source is hosted in a Git/Gerrit repository in Docbook XML
> format and can be downloaded at:
> 
>     git clone http://git.whamcloud.com/doc/manual lustre-manual

That doesn't work for me:

  % git clone http://review.whamcloud.com/doc/manual  lustre-manual
  Cloning into lustre-manual...
  fatal: http://review.whamcloud.com/doc/manual/info/refs not found: did
    you run git update-server-info on the server?

I've only been able to check out the manual source directly from gerrit:

  git clone http://review.whamcloud.com/p/doc/manual lustre-manual

or,

  git clone ssh://nedbass at review.whamcloud.com:29418/doc/manual lustre-manual


Ned
