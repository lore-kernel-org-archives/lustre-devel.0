From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 25 Sep 2015 11:50:14 +0200
Subject: [lustre-devel] [PATCH 32/37] staging/lustre: use 64-bit times
	for exp_last_request_time
In-Reply-To: <989D1FF5-705C-42EA-A41F-6CAD00BF53E4@intel.com>
References: <1443035640-1617003-1-git-send-email-arnd@arndb.de>
	<3415466.Q2DxJVi5PK@wuerfel>
	<989D1FF5-705C-42EA-A41F-6CAD00BF53E4@intel.com>
Message-ID: <2907593.hTFjyphPBj@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Friday 25 September 2015 01:07:43 Drokin, Oleg wrote:
> 
> These do seem to be working fine in my testing.
> 
> I also noticed we can remove some more stuff in at least fid/ dir so
> I created some patches on top of your tree:
> https://github.com/verygreen/linux/tree/fidcleanup
> 
> Also I've looked a bit into nm and I don't see a straight way of cross referencing
> which globally visible functions are not really used by anything.
> Do you have a handy recipe for that?
> 
> 

I usually use ad-hoc shell commands. This time, my history has these
commands:

find build/tmp/drivers/staging/lustre/ -name \*.o | grep -v built-in | xargs nm | grep -w U | cut -f 11- -d\  | sort -u > refs
find build/tmp/drivers/staging/lustre/lustre/obdclass/ -name \*.o | grep -v built-in | xargs nm | grep -w [A-TV-Z] | grep -v __ksymtab | grep -v __crc | cut -f 3 -d \  | sort -u > defs
diff -u defs refs | grep ^-  | cut -f 2 -d- | while read i ; do echo ==== $i ==== ; git grep -w $i ; done | less

I'm sure this could be done in a more robust and cleaner way, and probably has
been done before. If someone has a good way of doing this generically, we could
add that to the scripts/ directory and get get more people to analyse the
staging drivers (or their own code elsewhere) this way.

Note that I only did this for symbols defined in obdclass and ptlrpc, there
are plenty more in the other modules. Also, most of the findings are for
symbols that should be marked 'static', because they have only users in the
file that they are defined in. Doing that would lead to better code generation.

Two related things I'd do when cleaning up a code base are to check all
the EXPORT_SYMBOL statements and remove the ones that are not used in another
module, and to check for global identifiers that are missing a proper prefix
and should be renamed (e.g. dirty_cnt, dump_lsm, lock_handle_ops, our_vma,
pool_hash_operations, target_send_reply, at_max, dump_exports, ...).

	Arnd
