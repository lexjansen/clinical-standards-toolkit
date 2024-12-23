package com.sas.ptc.transform.xml;

import com.sas.ptc.util.StringUtils;

/**
 * Copyright (c) 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Thrown if the name and version of a standard, as given in the parameters, does not match any standard known to the
 * system.
 */
public class TransformNotFoundException extends Exception {

    private static final long serialVersionUID = 1L;
    private final String standardName;
    private final String standardVersion;
    private final AvailableTransforms availableTransforms;

    /**
     * Constructs an instance of this exception.
     * 
     * @param standardName The requested standard name
     * @param standardVersion The requested standard version
     * @param availableTransforms The current transform repository, in which no match for the given name and version was
     *            found
     */
    public TransformNotFoundException(final String standardName, final String standardVersion,
        final AvailableTransforms availableTransforms) {
        this.standardName = standardName;
        this.standardVersion = standardVersion;
        this.availableTransforms = availableTransforms;
    }

    /**
     * The name that was given.
     * 
     * @return The name of the standard
     */
    public String getStandardName() {
        return standardName;
    }

    /**
     * The version that was given.
     * 
     * @return The version of the standard
     */
    public String getStandardVersion() {
        return standardVersion;
    }

    /**
     * Gets the current transform repository, in which no match for the given name and version was found.
     * 
     * @return The transform repository
     */
    public AvailableTransforms getAvailableTransforms() {
        return availableTransforms;
    }

    /**
     * Returns the String generated by this class's toString() method
     * 
     * @return A message giving human-readable details of the Exception
     */
    @Override
    public String getMessage() {
        return this.toString();
    }

    /**
     * A String detailing the nature of the exception, including the name and version that was not found, as well as w
     * full listing of those standards known to the system.
     * 
     * @return a String representation of this instance
     */
    @Override
    public String toString() {
        final StringBuffer sb = new StringBuffer();

        sb.append("Standard '").append(getStandardName()).append("', version '").append(getStandardVersion())
            .append("' was not recognized.");
        sb.append(StringUtils.NEWLINE);
        sb.append(getAvailableTransforms().toString());
        sb.append(StringUtils.NEWLINE);

        return sb.toString();
    }

}
