From: Peter Jones <pjones@whamcloud.com>
Date: Fri, 31 Jan 2020 12:53:21 +0000
Subject: [lustre-devel] LU-12759 not in 2.12
In-Reply-To: <c8caac87-3406-6692-ec4a-4c2e234d4829@pdc.kth.se>
References: <0377f0de-25e8-db29-e59a-ef885bcd1e7d@pdc.kth.se>
 <94C86C98-64D5-445C-98E8-F695C4AD163D@ddn.com>
 <c8caac87-3406-6692-ec4a-4c2e234d4829@pdc.kth.se>
Message-ID: <4965B65D-E55A-4285-921D-BCEDC57099B0@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ok, well, this issue is included in the 2.12.4 RC1 build that is presently undergoing release testing.

?On 2020-01-07, 9:48 AM, "Mattias Claesson" <slas+lustre@pdc.kth.se> wrote:

    Hi Peter,
    
    Sorry for not answering earlier.
    
    > The short answer is because nobody has flagged it for inclusion. Do
    > you consider that there would still be value to include it now that a
    > fix for LU-12120 has landed?
    Ok. I'm not too familiar with what should go into which version stream,
    but since 2.12 is the current LTS version, and I would consider this
    (set parameters are "forgotten") a separate bug in itself, it seems
    natural to me to include it there also. The fewer patches we need to
    remember to apply when using the LTS version the better, I would say.
    And I assume there are other cases also when one would want to turn off
    'grant_shrink', even when not trying to mitigate LU-12120, since the
    feature was already (mostly) implemented :)
    
    Mattias
    PDC-staff
    
