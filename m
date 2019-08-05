From: Artem Blagodarenko <c17828@cray.com>
Date: Mon, 5 Aug 2019 07:31:14 +0000
Subject: [lustre-devel] [PATCH 08/22] ext4: kill off struct dx_root
In-Reply-To: <87ftmypt62.fsf@notabene.neil.brown.name>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-9-git-send-email-jsimmons@infradead.org>
 <87ftmypt62.fsf@notabene.neil.brown.name>
Message-ID: <7EE075AC-4F75-4A5F-A13B-88D1E15E714C@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We need this for dirdata feature.

?On 22/07/2019, 07:52, "NeilBrown" <neilb@suse.com> wrote:

    On Sun, Jul 21 2019, James Simmons wrote:
    
    > Use struct dx_root_info directly.
    
    This looks like a style change.
    Instead of a 'struct' that models the start of an on-disk directory
    block, the location of some fields is done using calculations instead.
    
    Why would we want to do that?  Might we want dx_root_info to be at a
    different offset in the directory ??
    
    NeilBrown
    
