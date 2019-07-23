From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 23 Jul 2019 02:07:27 +0000
Subject: [lustre-devel] [PATCH 08/22] ext4: kill off struct dx_root
In-Reply-To: <87ftmypt62.fsf@notabene.neil.brown.name>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-9-git-send-email-jsimmons@infradead.org>,
 <87ftmypt62.fsf@notabene.neil.brown.name>
Message-ID: <F5225915-150C-4DCD-8262-318538442030@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is needed so that we can add extra data to struct ext4_dir_entry
(Lustre FID) via the "dirdata" feature, and struct dx_root assumes "." and
".." entries are a fixed size.

So there is a reason for the patch, and I think it would be acceptable
upstream. Artem @ Cray has an updated version of this patch that
was submitted upstream to linux-ext4 and reviewed, but it needs to
be refreshed again. 

Cheers, Andreas

> On Jul 21, 2019, at 22:52, NeilBrown <neilb@suse.com> wrote:
> 
>> On Sun, Jul 21 2019, James Simmons wrote:
>> 
>> Use struct dx_root_info directly.
> 
> This looks like a style change.
> Instead of a 'struct' that models the start of an on-disk directory
> block, the location of some fields is done using calculations instead.
> 
> Why would we want to do that?  Might we want dx_root_info to be at a
> different offset in the directory ??
> 
> NeilBrown
