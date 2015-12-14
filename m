From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Dec 2015 10:08:03 +0100
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: Rename a jump label
 for ptlrpc_req_finished() calls
In-Reply-To: <20151214065325.GS5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7884.5050407@users.sourceforge.net> <20151214065325.GS5284@mwanda>
Message-ID: <566E86F3.9010209@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> Markus, please stop sending these things to rename out labels unless
> there is a bug.  CodingStyle allows out labels.

How does this feedback fit to information like the following?

"?
Chapter 7: ?
?
Choose label names which say what the goto does or why the goto exists.
? Avoid using GW-BASIC names ?
?"

Regards,
Markus
