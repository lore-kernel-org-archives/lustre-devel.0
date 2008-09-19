From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Fri, 19 Sep 2008 10:39:48 -0700
Subject: [Lustre-devel] Changelog API
Message-ID: <48D3E3E4.1030006@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A metadata changelog feature will be added in Lustre 2.0.  Changelogs 
are per-MDD persistent logs that record namespace change events, e.g. 
file creation, deletion, rename, mtime changes, etc.  Progress can be 
followed in bug 15699.


Changelog API


Configuring changelogs - lctl commands:
> lctl set_param mdd.*.changelog <on|off>
Enable/disable changelog record keeping

> lctl set_param -n mdd.*.changelog_mask "[[+|-]<event>] ..."
Set or modify the event types that are recorded in the changelog
e.g. > lctl set_param  mdd.*.changelog_mask "all -attr -slink -open -close"
     > lctl get_param "mdd.*.changelog_mask"
     mdd.lustre-MDT0000.changelog_mask=
     MARK CREAT MKDIR HLINK UNLNK RMDIR RNMFM RNMTO IOCTL TRUNC XATTR UNKNW


Using changelogs - LFS commands:
> lfs diff
Show the metadata changes in a filesystem between two snapshot times.
usage: diff [--follow] <mdtname> [startrec [endrec]]
The --follow flag causes this command to block waiting for new changelog events.

> lfs clear_changelog
clear_changelog: Purge old changelog records up to <endrec> to free up space.
usage: clear_changelog <mdtname> <endrec>


Data format is ascii text, 1 record per line:
<record_#> <commandtype> <timestamp> t=<target_fid> p=<parent_fid> <filename>

xen1:/r/cfs/b_hd_changelog/lustre/tests# lfs diff lustre
1 00MARK  4405821883 t=[0x0/0x10001] p=[0x0/0x0] mdd_obd-lustre-MDT0000-0
2 02MKDIR 4405821890 t=[0x100000400/0x5] p=[0x100000400/0x4] pics
3 02MKDIR 4405821892 t=[0x100000400/0x6] p=[0x100000400/0x5] 2008
4 02MKDIR 4405821894 t=[0x100000400/0x7] p=[0x100000400/0x6] zachy
5 01CREAT 4405821898 t=[0x100000400/0x8] p=[0x100000400/0x7] timestamp
6 01CREAT 4405821904 t=[0x100000400/0x9] p=[0x100000400/0x7] pic1.jpg
7 07RNMFM 4405821915 t=[0x100000400/0x7] p=[0x100000400/0x6] zachy
8 08RNMTO 4405821915 t=[0x100000400/0x7] p=[0x100000400/0x5] zach
9 03HLINK 4405821922 t=[0x100000400/0x9] p=[0x100000400/0x6] portland.jpg
10 04SLINK 4405821926 t=[0x100000400/0xa] p=[0x100000400/0x5] desktop.jpg
11 05UNLNK 4405821929 t=[0x100000400/0xa] p=[0x100000400/0x5] desktop.jpg


Record types are:
MARK    internal record keeping
CREAT   regular file creation
MKDIR   directory creation
HLINK   hardlink
SLINK   softlink
UNLNK   regular file removal
RMDIR   directory removal
RNMFM   rename, original
RNMTO   rename, final
OPEN    file opened for write
CLOSE   file closed for write
IOCTL   ioctl on file or dir
TRUNC   regular file truncated
ATTR    attribute change
XATTR   extended attribute change
UNKNW   unknown op


Writing your own changelog consumer -- llapi interface:
int llapi_changelog_open(const char *mdtname, long long startrec);
  Returns a file descriptor for a read-only file representation of the changelog, starting from
record <startrec>.  The file descriptor can be used with select(2) or poll(2) to wait for new
events.

int llapi_changelog_clear(const char *mdtname, long long endrec);
  Permanently removes old changelog records through <endrec>, freeing up disk space.
