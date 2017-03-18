From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 18 Mar 2017 18:34:43 +0800
Subject: [lustre-devel] [PATCH/RFC] staging/lustre: Rework
	class_process_proc_param
In-Reply-To: <20170318062408.3207381-1-green@linuxhacker.ru>
References: <20170318062408.3207381-1-green@linuxhacker.ru>
Message-ID: <20170318103443.GA21943@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Mar 18, 2017 at 02:24:08AM -0400, Oleg Drokin wrote:
> Ever since sysfs migration, class_process_proc_param stopped working
> correctly as all the useful params were no longer present as lvars.
> Replace all the nasty fake proc writes with hopefully less nasty
> kobject attribute search and then update the attributes as needed.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> ---
> Al has quite rightfully complained in the past that class_process_proc_param
> is a terrible piece of code and needs to go.
> This patch is an attempt at improving it somewhat and in process drop
> all the user/kernel address space games we needed to play to make it work
> in the past (and which I suspect attracted Al's attention in the first place).
> 
> Now I wonder if iterating kobject attributes like that would be ok with
> you Greg, or do you think there is a better way?
> class_find_write_attr could be turned into something generic since it's
> certainly convenient to reuse same table of name-write_method pairs,
> but I did some cursory research and nobody else seems to need anything
> of the sort in-tree.
> 
> I know ll_process_config is still awful and I will likely just
> replace the current hack with kset_find_obj, but I just wanted to make
> sure this new approach would be ok before spending too much time on it.

I'm not quite sure what exactly you are even trying to do here.  What is
this interface?  Who calls it, and how?  What does it want to do?

You can look up attributes for a kobject easily in the show/store
functions (and some drivers just have a generic one and then you look at
the string to see which attribute you are wanting to reference.)  But
you seem to be working backwards here, why do you have to look up a
kobject?

What is wrong with the "normal" way to interact with kobject attributes
from sysfs?

What does your "process proc" function do?  Where does it get called
from?

totally confused,

greg k-h
