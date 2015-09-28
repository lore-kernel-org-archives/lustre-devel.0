From: Di Natale, Giuseppe <dinatale2@llnl.gov>
Date: Mon, 28 Sep 2015 20:08:48 +0000
Subject: [lustre-devel] lprocfs Helper Issues
Message-ID: <974262C966B9F640899A48EB96313E9A2C9DAA@PRDEXMBX-08.the-lab.llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings,

Recently, I've noticed that the lprocfs write frac int and u64 helpers have a few issues. The biggest issue is that neither function handles overflow/wrap. I also noticed very similar code that should be consolidated down and leveraged by both helpers.

I was thinking of refactoring the functions in the fashion described below.

int lprocfs_write_frac_helper_internal(char *buffer, unsigned long count, __u64 *val, int mult);
int lprocfs_write_frac_u64_helper_safe(const char __user *buffer, unsigned long count, __u64 *val, int mult);
int lprocfs_write_frac_helper_safe(const char __user *buffer, unsigned long count, int *val, int mult);

lprocfs_write_frac_helper_internal would handle parsing an unsigned long long from the kernel char buffer passed in. It will be responsible for detecting if a uint wrap occurs.

For lprocfs_write_frac_u64_helper_safe, the string "-1" will automatically return ULLONG_MAX. If any other string representing a negative number is passed in, an invalid value error code should be returned. If the multiplier is negative, that would also be treated as invalid. The units and multiplier logic can also be consolidated. It will use lprocfs_write_frac_helper_internal to handle the parsing.

lprocfs_write_frac_helper_safe will leverage lprocfs_write_frac_helper_internal. If lprocfs_write_frac_helper_internal indicates a wrap occurred, then we also have an invalid integer. Checks for integer overflow happen after a successful call to the internal helper. This is similar to how the current lprocfs_write_frac_helper functions.

It is also worth nothing, I plan to maintain the old helpers and their use can be gradually phased out once we are confident the refactored version is doing what it is supposed to.

Also, unrelated to the above, quick question about lctl. Is there a particular reason why the setting to be changed when using lctl set_param is echoed back to the user? I think it can be misleading in cases where the value set is not necessarily what is being reflected to the user (i.e. -1 for max value). That could be confusing to a user and they should be using lctl get_param to confirm their value was set anyways. Also, it would follow convention that unless an error happens, nothing is printed to console. Any disagreements on silencing lctl set_param?

Thanks,
Giuseppe Di Natale
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150928/d1f45a71/attachment.htm>
