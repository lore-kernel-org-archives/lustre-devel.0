From: Olaf Weber <olaf@sgi.com>
Date: Mon, 5 Oct 2015 19:51:13 +0200
Subject: [lustre-devel] Multi-Rail Debug Information
In-Reply-To: <D2376E9E.10EEA5%andreas.dilger@intel.com>
References: <D2376E9E.10EEA5%andreas.dilger@intel.com>
Message-ID: <5612B891.4020904@sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For debugging this kind of issue, I see several ways to provide useful 
information. One is for LNet to log the issues it sees, for example when 
sending a message on one interface times out and another one is selected.

The other one is maintaining some of this information in the interface 
state. This would be counters indicating how often an interface has seen 
timeouts and other unexpected conditions (which may or may not be actual 
errors). Retrieving the interface state should get you those counters as 
well. (To a first approximation: whenever you emit a log message for some 
condition, the relevant counter is bumped as well.)

The main problem with counters is that it becomes difficult to distinguish 
old from new errors. This is where decaying sums ("heat") might be useful. 
Ideally I'd get both, but if I have to choose just one I'll pick the 
lifetime count over the decaying one.

Olaf


On 05-10-15 08:20, Dilger, Andreas wrote:
> I think there are two separate issues here.  The message below is a PtlRPC layer message, so the important part is the target name and NID where the service is currently running.  That is enough to determine which _node_ the service is running on for diagnosing service problems (which is what PtlRPC cares about), but not which _path_ the message took.  This is true if there are LNet routers as well, so I don't think the multi-path usage is any worse than a routed configuration in this regard.
>
> I think if there is multi-rail LNet then any messages about channel failure need to be printed by the LNet layer.  This will allow debugging link-level failures as needed, even while the PtlRPC-level messages continue to work over alternate paths.
>
> Cheers, Andreas
>
> PS: I changed the subject from "Channel Bonding" to "Multi-Rail" since I agree with Olaf that this project isn't really implementing a "bonded" network (which IMHO implies configuration of a bonded device used as the target NID), but rather an "self-configuring multi-path redundancy" which IMHO is more robust and easier to use (little config in many cases, and no need for an external NID naming service).
> --
> Andreas Dilger
> Lustre Software Architect
> Intel High Performance Data Division
>
> On 2015/10/02, 9:03 AM, "lustre-devel on behalf of DEGREMONT Aurelien" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of aurelien.degremont at cea.fr<mailto:aurelien.degremont@cea.fr>> wrote:
>
> Hi
>
> As discussed at last Developer Summit, my concern is about transparent interface switching, without upper layer knowing it.
> I'm not talking about a lot of interface details, others already talked about that. I thinking about error messages and admins which are not Lustre experts.
>
> This is a typically timeout error message you can get on a Lustre client. You can see a lustre target (here MDT0000) and a NID, especially an IP address.
>
> [4863147.960698] Lustre: 25163:0:(client.c:1939:ptlrpc_expire_one_request()) @@@ Request sent has timed out for slow reply: [sent 1443794470/real 1443794470]  req at ffff880612a00c00 x1509752994606324/t0(0) o38->lustre-MDT0000-mdc-ffff88062dea2000 at 10.2.10.13@o2ib:12/10<mailto:lustre-MDT0000-mdc-ffff88062dea2000@10.2.10.13@o2ib:12/10> lens 400/544 e 0 to 1 dl 1443794476 ref 1 fl Rpc:XN/0/ffffffff rc 0/-1
>
> If this error is due to LNET taking another link, either on client side or server side and this link is sick/flacky/buggy, ... *this should not be silent*! Ideally this NID should be updated in this error message to reflect the route change.
> I do not have a strong opinion on the way this error should be reported, but I just wanted the case where : the network error is reported only in debug message and this error message is displayed as-is, without any idea that LNET did some magic stuff that failed.
>
>
>
> Aur?lien
>
> Le 28/09/2015 21:30, Amir Shehata a ?crit :
> Hello,
>
> As a followup on the discussion in the LAD developer summit, regarding ensuring that there is enough debug information provided as part of the Channel Bonding solution, I'm sending this email to ask for ideas on what type of debug information you would like to see.
>
> thanks
> amir
>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>


-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696796
                            Veldzigt 2b       Fax:    +31(0)30-6696799
Sr Software Engineer       3454 PW de Meern  Vnet:   955-6796
Storage Software           The Netherlands   Email:  olaf at sgi.com
