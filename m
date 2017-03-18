From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 18 Mar 2017 11:17:55 -0400
Subject: [lustre-devel] [PATCH/RFC] staging/lustre: Rework
	class_process_proc_param
In-Reply-To: <20170318103443.GA21943@kroah.com>
References: <20170318062408.3207381-1-green@linuxhacker.ru>
	<20170318103443.GA21943@kroah.com>
Message-ID: <9C67F0F2-005F-4D70-8320-9255625CB543@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Mar 18, 2017, at 6:34 AM, Greg Kroah-Hartman wrote:

> On Sat, Mar 18, 2017 at 02:24:08AM -0400, Oleg Drokin wrote:
>> Ever since sysfs migration, class_process_proc_param stopped working
>> correctly as all the useful params were no longer present as lvars.
>> Replace all the nasty fake proc writes with hopefully less nasty
>> kobject attribute search and then update the attributes as needed.
>> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
>> ---
>> Al has quite rightfully complained in the past that class_process_proc_param
>> is a terrible piece of code and needs to go.
>> This patch is an attempt at improving it somewhat and in process drop
>> all the user/kernel address space games we needed to play to make it work
>> in the past (and which I suspect attracted Al's attention in the first place).
>> 
>> Now I wonder if iterating kobject attributes like that would be ok with
>> you Greg, or do you think there is a better way?
>> class_find_write_attr could be turned into something generic since it's
>> certainly convenient to reuse same table of name-write_method pairs,
>> but I did some cursory research and nobody else seems to need anything
>> of the sort in-tree.
>> 
>> I know ll_process_config is still awful and I will likely just
>> replace the current hack with kset_find_obj, but I just wanted to make
>> sure this new approach would be ok before spending too much time on it.
> 
> I'm not quite sure what exactly you are even trying to do here.  What is
> this interface?  Who calls it, and how?  What does it want to do?

This is a configuration client code.
Management server has ability to pass down config information in the form of:
fsname.subsystem.attribute=value to clients and other servers
(subsystem determines if it's something of interest of clients or servers or
both).
This could be changed in the real time - i.e. you update it on the server and
that gets propagated to all the clients/servers, so no need to ssh into
every node to manually apply those changes and worry about client restarts
(the config is remembered at the management server and would be applied to any
new nodes connecting/across server restarts and such).

So the way it then works then is once the string fsname.subsystem.attribute=value is delivered to the client, we find all instances of filesystem with fsname and then
all subsystems within it (one kobject per subsystem instance) and then update the
attributes to the value supplied.

The same filesystem might be mounted more than once and then some layers might have
multiple instances inside a single filesystems.

In the end it would turn something like lustre.osc.max_dirty_mb=128 into
writes to
/sys/fs/lustre/osc/lustre-OST0000-osc-ffff8800d75ca000/max_dirty_mb and
/sys/fs/lustre/osc/lustre-OST0001-osc-ffff8800d75ca000/max_dirty_mb
without actually iterating in sysfs namespace.

The alternative we considered is we can probably just do an upcall and have
a userspace tool called with the parameter verbatim and try to figure it out,
but that seems a lot less ideal, and also we'll get a bunch of complications from
containers and such too, I imagine.

The function pre-this patch is assuming that all these values are part of
a list of procfs values (no longer true after sysfs migration) so just iterates
that list and calls the write for matched names (but also needs to supply a userspace
buffer so looks much uglier too).

Hopefully this makes at least some sense.

> You can look up attributes for a kobject easily in the show/store
> functions (and some drivers just have a generic one and then you look at
> the string to see which attribute you are wanting to reference.)  But
> you seem to be working backwards here, why do you have to look up a
> kobject?

But that leads to the need to list attribute names essentially twice:
once for the attributes list, once in the show/set function to figure
out how to deal with that name.

> What is wrong with the "normal" way to interact with kobject attributes
> from sysfs?
> 
> What does your "process proc" function do?  Where does it get called
> from?
> 
> totally confused,
> 
> greg k-h
