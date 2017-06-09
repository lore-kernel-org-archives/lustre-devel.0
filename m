From: Cory Spitz <spitzcor@cray.com>
Date: Fri, 9 Jun 2017 20:13:49 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: llite: Replace the
 symbolic file permission mode with the numeric one
In-Reply-To: <20170608172541.GA2314@home>
References: <20170608172541.GA2314@home>
Message-ID: <78EAE665-9BDD-4EF4-8793-3FC55D565AFB@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Roman,
You have ?0007? in the description vs. ?0777? in the patch.
-Cory


On 6/8/17, 12:25 PM, "lustre-devel on behalf of Roman Storozhenko" <lustre-devel-bounces at lists.lustre.org on behalf of romeusmeister@gmail.com> wrote:

    Replaces S_IRWXUGO with 0007. The reason is that symbolic permissions


+		mode = data->ioc_type != 0 ? data->ioc_type : 0777;
 
