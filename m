From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 6 Feb 2012 09:36:06 -0700
Subject: [Lustre-devel] oldest lustre supported SUSE kernel
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E803B132@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805E803B132@MX09A.corp.emc.com>
Message-ID: <9C0BB3E3-D296-42A0-89EA-67F299215215@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-02-06, at 2:53, <tao.peng@emc.com> wrote:
> 
> As I know, the oldest lustre supported RHEL kernel is 2.6.18-latest. What is the oldest SUSE kernel? 2.6.32-latest?

That depends on which version of Lustre you are asking about, and whether you are asking about the client or server.

For Lustre 2.2+ servers it will be SLES11 SP1 (2.6.32), since it matches RHEL6 (2.6.32).

For clients it is RHEL5 (2.6.18) and SLES11 SP0 (2.6.27). 

Cheers, Andreas
