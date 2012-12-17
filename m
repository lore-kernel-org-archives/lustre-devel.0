From: Oleg Drokin <green@whamcloud.com>
Date: Mon, 17 Dec 2012 12:30:36 -0500
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <50CF51D4.2090101@tacc.utexas.edu>
References: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
	<50CF51D4.2090101@tacc.utexas.edu>
Message-ID: <550C3ACC-1D29-451A-945C-F394214B095C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Dec 17, 2012, at 12:09 PM, John Hammond wrote:
> I have been wondering about wrappers and typedefs not affected by this change, for example cfs_get_cpu(), cfs_atomic_read() and cfs_proc_dir_entry_t.  In new code and patches should we use the cfs names or their Linux equivalents, get_cpu(), atomic_read(), and struct proc_dir_entry?

Those will be converted in later patches.
As such it's better not to submit cfs_ style names already, though no super big harm if not.

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
