# Cloud Foundry Java Buildpack
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/jre'
require 'java_buildpack/jre/tokenized_version'

module JavaBuildpack::Jre

  # A resolver that selects values from a collection based on a set of rules governing wildcards
  class VersionResolver

    # Resolves a version from a collection of versions.  The +candidate_version+ must be structured like:
    #   * up to three numeric components, followed by an optional string component
    #   * the final component may be a +
    # The resolution returns the maximum of the versions that match the candidate version
    #
    # @param [String, nil] candidate_version the version, possibly containing a wildcard, to resolve
    # @param [String, nil] default_version the version, possibly containing a wildcard, to resolve if
    #                                      +candidate_version+ is +nil+
    # @param [Array<String>] versions the collection of versions to resolve against
    # @return [String] the resolved version
    # @raise if no version can be resolved
    def self.resolve(candidate_version, default_version, versions)
      tokenized_candidate_version = TokenizedVersion.new(
        candidate_version.nil? || candidate_version.empty? ? default_version : candidate_version)
      tokenized_versions = versions.map { |version| TokenizedVersion.new(version, false) }

      version = tokenized_versions
        .find_all { |tokenized_version| matches tokenized_candidate_version, tokenized_version }
        .max { |a, b| a <=> b }

      raise "No version resolvable for '#{candidate_version}' in #{versions.join(', ')}" if version.nil?
      version.to_s
    end

    private

    def self.matches(tokenized_candidate_version, tokenized_version)
      (0..3).all? do |i|
        tokenized_candidate_version[i].nil? ||
        tokenized_candidate_version[i] == TokenizedVersion::WILDCARD ||
        tokenized_candidate_version[i] == tokenized_version[i]
      end
    end

  end

end
